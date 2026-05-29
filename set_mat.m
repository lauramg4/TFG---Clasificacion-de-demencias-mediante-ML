% Directorio donde tienes los archivos .set
data_folder = 'C:\Users\Laura\Documents\25-26\TFG\BBDD\DF';
file_list = dir(fullfile(data_folder, '*.set'));

% Añadir el directorio de EEGLAB al path (cambia la ruta según donde lo tengas instalado)
addpath('C:\Users\Laura\Documents\MATLAB\eeglab_current\eeglab2024.2'); 

% Inicializar EEGLAB
eeglab;

% Loop a través de cada archivo .set    
for i = 1:length(file_list)
    % Cargar el archivo .set
    EEG = pop_loadset('filename', file_list(i).name, 'filepath', data_folder);
    
    % Guardar como archivo .mat
    [~, name, ~] = fileparts(file_list(i).name);
    save(fullfile(data_folder, [name '.mat']), 'EEG');
    
    disp(['Archivo convertido: ' file_list(i).name]);
end