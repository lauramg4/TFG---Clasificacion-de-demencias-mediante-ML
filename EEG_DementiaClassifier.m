%% EEG_DementiaClassifier.m
% Script principal de configuración y lanzamiento.
% Define todos los parámetros comunes y llama a los runners específicos.
%
% Runners disponibles:
%   run_SVM_canales.m
%   run_RF_canales.m
%   run_SVM_regiones.m
%   run_RF_regiones.m

clear; clc;

% =========================================================================
%  1. RUTAS
% =========================================================================
base_path = uigetdir(pwd, 'Selecciona la carpeta de la base de datos (BBDD)');
if base_path == 0
    error('No se seleccionó ninguna carpeta. Ejecución cancelada.');
end

guardar_resultados = true;   % false → no se exporta ningún Excel
if guardar_resultados
    save_path = uigetdir(pwd, 'Selecciona la carpeta donde guardar los resultados');
    if save_path == 0
        error('No se seleccionó carpeta de resultados. Ejecución cancelada.');
    end
end

folder_AD  = fullfile(base_path, 'AD');
folder_FTD = fullfile(base_path, 'FTD');
folder_C   = fullfile(base_path, 'Control');

excel_AD  = fullfile(base_path, 'AD.xlsx');
excel_FTD = fullfile(base_path, 'FTD.xlsx');
excel_C   = fullfile(base_path, 'C.xlsx');

% =========================================================================
%  2. PARÁMETROS GENERALES
% =========================================================================
Fs  = 500;       % Frecuencia de muestreo (Hz)
rng(1);          % Semilla para reproducibilidad

% =========================================================================
%  3. BANDAS DE FRECUENCIA
% =========================================================================
bands = {
    'delta', [0.5  4];
    'theta', [4    8];
    'alpha', [8   13];
    'beta',  [13  30];
    'gamma', [30  50];
};

% =========================================================================
%  4. CANALES Y REGIONES
% =========================================================================
nombres_canales = {'Fp1','Fp2','F7','F3','Fz','F4','F8', ...
                   'T3','C3','Cz','C4','T4', ...
                   'T5','P3','Pz','P4','T6','O1','O2'};

num_canales = numel(nombres_canales);   % 19

regiones = {
    'FRONTAL',   {'Fp1','Fp2','F3','F4','F7','F8','Fz'};
    'TEMPORAL',  {'T3','T4','T5','T6'};
    'PARIETAL',  {'P3','P4','Pz'};
    'OCCIPITAL', {'O1','O2'};
    'CENTRAL',   {'C3','C4','Cz'};
};

% =========================================================================
%  5. HIPERPARÁMETROS DE LOS MODELOS
% =========================================================================
% --- SVM ---
svm_kernel        = 'rbf';
svm_standardize   = true;
svm_prior         = 'uniform';

% --- Random Forest ---
rf_num_trees      = 200;
rf_max_splits     = 20;
rf_prior          = 'uniform';

% --- Cross-validation ---
num_folds = 5;

% =========================================================================
%  6. MODALIDAD DE FEATURES
%     'eeg'       → solo potencias EEG
%     'multimodal' → EEG + variables clínicas (edad, sexo, MMSE)
% =========================================================================
modalidad = 'multimodal';   % Cambia a 'multimodal' para incluir clínicos
                            % Cambia a 'eeg' para no incluir clínicos
% =========================================================================
%  7. ANÁLISIS A EJECUTAR
%     Comenta/descomenta los runners que quieras lanzar
% =========================================================================

%run_SVM_canales;
% run_RF_canales;
% run_SVM_regiones;
 run_RF_regiones;
