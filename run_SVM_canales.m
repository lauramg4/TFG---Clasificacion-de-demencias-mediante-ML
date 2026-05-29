%% run_SVM_canales.m
% Runner: SVM canal a canal (19 canales).
% Requiere que EEG_DementiaClassifier.m haya sido ejecutado antes
% (carga variables del workspace compartido).

disp('========================================')
disp(' SVM — ANÁLISIS CANAL A CANAL')
disp('========================================')

% ---- Inicializar resultados ----
accuracy_all   = zeros(num_canales, 1);
recall_all     = zeros(num_canales, 3);   % columnas: AD, C, FTD
precision_all  = zeros(num_canales, 3);
f1_all         = zeros(num_canales, 3);

for canal = 1:num_canales

    try
        fprintf('Procesando canal %d (%s)...\n', canal, nombres_canales{canal})

        % ---- Extracción de features ----
        [power_abs_AD,  power_rel_AD]  = calcular_potencias(folder_AD,  canal, Fs, bands);
        [power_abs_FTD, power_rel_FTD] = calcular_potencias(folder_FTD, canal, Fs, bands);
        [power_abs_C,   power_rel_C]   = calcular_potencias(folder_C,   canal, Fs, bands);

        % ---- Construcción de la matriz de features ----
        switch modalidad
            case 'multimodal'
                [AD,  subj_AD]  = unir_clinicos(power_rel_AD,  power_abs_AD,  excel_AD);
                [FTD, subj_FTD] = unir_clinicos(power_rel_FTD, power_abs_FTD, excel_FTD);
                [C,   subj_C]   = unir_clinicos(power_rel_C,   power_abs_C,   excel_C);
            otherwise  % 'eeg'
                [~, subj_AD]  = unir_clinicos(power_rel_AD,  power_abs_AD,  excel_AD);
                [~, subj_FTD] = unir_clinicos(power_rel_FTD, power_abs_FTD, excel_FTD);
                [~, subj_C]   = unir_clinicos(power_rel_C,   power_abs_C,   excel_C);
                AD  = [power_rel_AD  power_abs_AD];
                FTD = [power_rel_FTD power_abs_FTD];
                C   = [power_rel_C   power_abs_C];
        end

        % ---- Etiquetas y sujetos ----
        X = [AD; C; FTD];

        Y = [repelem("AD",  size(AD,1))'; ...
            repelem("C",   size(C,1))'; ...
            repelem("FTD", size(FTD,1))'];

        subject_ids = [subj_AD; subj_C; subj_FTD];
       

        % ---- Cross-validation por sujeto ----
        [accuracy_all(canal), recall_all(canal,:), ...
         precision_all(canal,:), f1_all(canal,:)] = ...
            cv_clasificar(X, Y, subject_ids, num_folds, ...
                          'SVM', svm_kernel, svm_standardize, svm_prior, ...
                          [], []);

    catch ME
        fprintf(' [!] Error en canal %d: %s\n', canal, ME.message)
    end
end

% ---- Mostrar resultados ----
disp('--- RESULTADOS SVM CANALES ---')
for canal = 1:num_canales
    fprintf('\nCanal %d (%s)\n', canal, nombres_canales{canal})
    fprintf('  Accuracy : %.2f\n', accuracy_all(canal))
    fprintf('  Recall   AD: %.2f | C: %.2f | FTD: %.2f\n', ...
        recall_all(canal,1), recall_all(canal,2), recall_all(canal,3))
    fprintf('  F1       AD: %.2f | C: %.2f | FTD: %.2f\n', ...
        f1_all(canal,1), f1_all(canal,2), f1_all(canal,3))
end

% ---- Guardar ----
if guardar_resultados
    T = table((1:num_canales)', string(nombres_canales'), accuracy_all, ...
        recall_all(:,1),    recall_all(:,2),    recall_all(:,3), ...
        precision_all(:,1), precision_all(:,2), precision_all(:,3), ...
        f1_all(:,1),        f1_all(:,2),        f1_all(:,3), ...
        'VariableNames', {'Canal','Nombre','Accuracy', ...
                          'Recall_AD','Recall_C','Recall_FTD', ...
                          'Precision_AD','Precision_C','Precision_FTD', ...
                          'F1_AD','F1_C','F1_FTD'});
    nombre_archivo = sprintf('res_SVM_canales_%s_rng1.xlsx', modalidad);
    writetable(T, fullfile(save_path, nombre_archivo));
    fprintf('\nResultados guardados en: %s\n', nombre_archivo)
end