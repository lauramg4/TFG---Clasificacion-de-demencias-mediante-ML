function [power_abs, power_rel] = calcular_potencias(data_folder, canal, Fs, bands)
%CALCULAR_POTENCIAS  Extrae potencias absolutas y relativas por bandas.
%
%   [power_abs, power_rel] = calcular_potencias(data_folder, canal, Fs, bands)
%   [power_abs, power_rel] = calcular_potencias(data_folder, canal, Fs, bands, max_duration_s)
%
%   Entradas:
%     data_folder    - Carpeta con los .mat del grupo
%     canal          - Índice del canal a extraer
%     Fs             - Frecuencia de muestreo (Hz)
%     bands          - Cell array Nx2 {'nombre', [f_low f_high]}
%     max_duration_s - (Opcional) Duración máxima en segundos a conservar.
%                      Se recorta desde el FINAL de la grabación para
%                      descartar los primeros instantes (más ruidosos).
%                      Si no se especifica, se usa la grabación completa.
%
%   Salidas:
%     power_abs - Matriz [num_subjects x n_bands], potencia absoluta
%     power_rel - Matriz [num_subjects x n_bands], potencia relativa



file_list    = dir(fullfile(data_folder, '*.mat'));
num_subjects = length(file_list);
n_bands      = size(bands, 1);

power_abs = zeros(num_subjects, n_bands);
power_rel = zeros(num_subjects, n_bands);

for i = 1:num_subjects

    eeg_file = load(fullfile(data_folder, file_list(i).name));
    eeg_data = double(eeg_file.EEG.data(canal, :));

   % ---- Recorte temporal ----
duration_analysis_s = 300;   % 5 min
offset_s = 60;               % quitar primer minuto

analysis_samples = duration_analysis_s * Fs;
offset_samples   = offset_s * Fs;

signal_length = length(eeg_data);

% Caso 1: señales >= 6 min
if signal_length >= (analysis_samples + offset_samples)

    start_idx = offset_samples + 1;
    end_idx   = offset_samples + analysis_samples;

    eeg_data = eeg_data(start_idx:end_idx);

% Caso 2: señales más cortas
elseif signal_length >= analysis_samples

    eeg_data = eeg_data(end-analysis_samples+1:end);

else
    error('La señal %s tiene menos de 5 minutos.', file_list(i).name);

end
    % ---- Potencia total (banda válida del dataset: 0.5–45 Hz) ----
    % El filtro paso bajo del dataset llega hasta 45 Hz,
    % por lo que la banda 45–50 Hz está atenuada y no es fiable.
    total_power = bandpower(eeg_data, Fs, [0.5 45]);

    % ---- Potencia por banda ----
    for b = 1:n_bands
        freq_range = bands{b, 2};
        bp = bandpower(eeg_data, Fs, freq_range);
        power_abs(i, b) = bp;
        power_rel(i, b) = bp / total_power;
    end

end

end