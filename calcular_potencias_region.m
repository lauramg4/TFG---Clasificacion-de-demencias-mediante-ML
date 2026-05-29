function [power_abs, power_rel] = calcular_potencias_region(folder, canales_idx, Fs, bands)
%CALCULAR_POTENCIAS_REGION  Extrae y concatena potencias de todos los canales
%                            de una región cerebral.
%
%   [power_abs, power_rel] = calcular_potencias_region(folder, canales_idx, Fs, bands)
%   [power_abs, power_rel] = calcular_potencias_region(folder, canales_idx, Fs, bands, max_duration_s)
%
%   En lugar de promediar los canales de la región (lo que puede enmascarar
%   diferencias entre canales), se concatenan horizontalmente. Así el vector
%   de características por sujeto es:
%       [banda1_c1 ... banda5_c1 | banda1_c2 ... banda5_c2 | ...]
%   preservando información espacial dentro de la región.
%
%   Entradas:
%     folder         - Carpeta con los .mat del grupo
%     canales_idx    - Vector de índices de los canales de la región
%     Fs             - Frecuencia de muestreo (Hz)
%     bands          - Cell array Nx2 {'nombre', [f_low f_high]}
%     max_duration_s - (Opcional) Duración máxima en segundos — ver calcular_potencias
%
%   Salidas:
%     power_abs - Matriz [num_subjects x (n_bands * n_canales)]
%     power_rel - Matriz [num_subjects x (n_bands * n_canales)]


power_abs_all = [];   % Se irán concatenando columnas: [sujetos x bandas x canal]
power_rel_all = [];

for c = 1:length(canales_idx)
    canal = canales_idx(c);
    [p_abs, p_rel] = calcular_potencias(folder, canal, Fs, bands);

    % Acumular a lo largo de la 3ª dimensión (un "plano" por canal)
    power_abs_all = cat(3, power_abs_all, p_abs);
    power_rel_all = cat(3, power_rel_all, p_rel);
end

% ---- Concatenar en vez de promediar ----
% Antes:  power_abs = mean(power_abs_all, 3)  → [sujetos x n_bandas]
% Ahora:  reshape para obtener              → [sujetos x (n_bandas * n_canales)]
% Cada fila: [b1_c1 b2_c1 ... b5_c1  b1_c2 b2_c2 ... b5_c2  ...]
power_abs = reshape(power_abs_all, size(power_abs_all, 1), []);
power_rel = reshape(power_rel_all, size(power_rel_all, 1), []);

end