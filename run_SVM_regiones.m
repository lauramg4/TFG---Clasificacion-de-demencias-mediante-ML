%% run_SVM_regiones.m
% Runner: SVM por regiones cerebrales (5 regiones).
% Requiere que EEG_DementiaClassifier.m haya sido ejecutado antes.

disp('========================================')
disp(' SVM — ANÁLISIS POR REGIONES')
disp('========================================')

num_regiones = size(regiones, 1);

% ---- Inicializar resultados ----
accuracy_all   = zeros(num_regiones, 1);
recall_all     = zeros(num_regiones, 3);
precision_all  = zeros(num_regiones, 3);
f1_all         = zeros(num_regiones, 3);

for r = 1:num_regiones

    nombre_region  = regiones{r,1};
    canales_region = regiones{r,2};

    try
        fprintf('Procesando región: %s...\n', nombre_region)

        % ---- Índices de canales de la región ----
        idx = find(ismember(nombres_canales, canales_region));

        % ---- Extracción de features ----
        [power_abs_AD,  power_rel_AD]  = calcular_potencias_region(folder_AD,  idx, Fs, bands);
        [power_abs_FTD, power_rel_FTD] = calcular_potencias_region(folder_FTD, idx, Fs, bands);
        [power_abs_C,   power_rel_C]   = calcular_potencias_region(folder_C,   idx, Fs, bands);

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
        [accuracy_all(r), recall_all(r,:), ...
         precision_all(r,:), f1_all(r,:)] = ...
            cv_clasificar(X, Y, subject_ids, num_folds, ...
                          'SVM', svm_kernel, svm_standardize, svm_prior, ...
                          [], []);

    catch ME
        fprintf(' [!] Error en región %s: %s\n', nombre_region, ME.message)
    end
end

% ---- Mostrar resultados ----
disp('--- RESULTADOS SVM REGIONES ---')
for r = 1:num_regiones
    fprintf('\nRegión: %s\n', regiones{r,1})
    fprintf('  Accuracy : %.2f\n', accuracy_all(r))
    fprintf('  Recall   AD: %.2f | C: %.2f | FTD: %.2f\n', ...
        recall_all(r,1), recall_all(r,2), recall_all(r,3))
    fprintf('  F1       AD: %.2f | C: %.2f | FTD: %.2f\n', ...
        f1_all(r,1), f1_all(r,2), f1_all(r,3))
end

% ---- Guardar ----
if guardar_resultados
    T = table(string(regiones(:,1)), accuracy_all, ...
        recall_all(:,1),    recall_all(:,2),    recall_all(:,3), ...
        precision_all(:,1), precision_all(:,2), precision_all(:,3), ...
        f1_all(:,1),        f1_all(:,2),        f1_all(:,3), ...
        'VariableNames', {'Region','Accuracy', ...
                          'Recall_AD','Recall_C','Recall_FTD', ...
                          'Precision_AD','Precision_C','Precision_FTD', ...
                          'F1_AD','F1_C','F1_FTD'});
    nombre_archivo = sprintf('res_SVM_regiones_%s_rng1.xlsx', modalidad);
    writetable(T, fullfile(save_path, nombre_archivo));
    fprintf('\nResultados guardados en: %s\n', nombre_archivo)
end