function [accuracy, recall, precision, f1] = cv_clasificar( ...
    X, Y, subject_ids, num_folds, tipo_modelo, ...
    svm_kernel, svm_standardize, prior, rf_num_trees, rf_max_splits)
%CV_CLASIFICAR  Cross-validation por sujeto + cálculo de métricas.
%
%   [accuracy, recall, precision, f1] = cv_clasificar(
%       X, Y, subject_ids, num_folds, tipo_modelo,
%       svm_kernel, svm_standardize, prior, rf_num_trees, rf_max_splits)
%
%   Entradas:
%     X             - Matriz de features (filas = muestras)
%     Y             - Etiquetas (string array: "AD", "FTD", "C")
%     subject_ids   - Vector con ID de sujeto para cada muestra
%     num_folds     - Número de folds para K-Fold (por sujeto)
%     tipo_modelo   - 'SVM' o 'RF'
%     svm_kernel    - Kernel del SVM ('rbf', 'linear', ...) — ignorado si RF
%     svm_standardize - true/false — ignorado si RF
%     prior         - Prior del modelo ('uniform', ...)
%     rf_num_trees  - Número de árboles (RF) — ignorado si SVM
%     rf_max_splits - MaxNumSplits por árbol (RF) — ignorado si SVM
%
%   Salidas:
%     accuracy  - Escalar
%     recall    - Vector 1x3 [AD, C, FTD]
%     precision - Vector 1x3 [AD, C, FTD]
%     f1        - Vector 1x3 [AD, C, FTD]

% ---- Tipos correctos ----
subject_ids = string(subject_ids(:));   % ← siempre string array, columna
Y           = string(Y(:));

class_names = ["AD", "C", "FTD"];


subjects = unique(subject_ids);

% ---- Etiqueta de cada sujeto para estratificación ----
subject_labels = strings(length(subjects),1);

for s = 1:length(subjects)

    idx_s = find(subject_ids == subjects(s), 1);

    subject_labels(s) = Y(idx_s);

end

subject_labels = categorical(subject_labels, cellstr(class_names));

%cv = cvpartition(length(subjects), 'KFold', num_folds);
cv = cvpartition(subject_labels, ...
    'KFold', num_folds, ...
    'Stratify', true);

% all_Y_test = [];
% all_Y_pred = [];
all_Y_test = strings(0,1);
all_Y_pred = strings(0,1);

for i = 1:cv.NumTestSets

    test_subj  = subjects(test(cv, i));
    train_subj = subjects(training(cv, i));

    test_idx  = ismember(subject_ids, test_subj);
    train_idx = ismember(subject_ids, train_subj);

    X_train = X(train_idx, :);
    Y_train = Y(train_idx);
    X_test  = X(test_idx, :);
    Y_test  = Y(test_idx);

    switch upper(tipo_modelo)
        case 'SVM'
            model = fitcecoc(X_train, Y_train, ...
                'Learners', templateSVM( ...
                    'KernelFunction', svm_kernel, ...
                    'Standardize',    svm_standardize), ...
                'ClassNames', class_names, ...
                'Prior', prior);

        case 'RF'
            model = fitcensemble(X_train, Y_train, ...
                'Method',            'Bag', ...
                'NumLearningCycles', rf_num_trees, ...
                'Learners',          templateTree('MaxNumSplits', rf_max_splits), ...
                'ClassNames',        class_names, ...
                'Prior',             prior);

        otherwise
            error('cv_clasificar: tipo_modelo debe ser ''SVM'' o ''RF''.')
    end

    Y_pred = predict(model, X_test);
    Y_pred = string(Y_pred);

    all_Y_test = [all_Y_test; Y_test];  
    all_Y_pred = [all_Y_pred; Y_pred];  
end

% ---- Accuracy global ----
accuracy = mean(all_Y_pred == all_Y_test);

% ---- Métricas por clase (orden: AD, C, FTD) ----
cm = confusionmat(all_Y_test, all_Y_pred, 'Order', class_names);

recall    = zeros(1, 3);
precision = zeros(1, 3);
f1        = zeros(1, 3);

for j = 1:3
    TP = cm(j, j);
    FN = sum(cm(j, :)) - TP;
    FP = sum(cm(:, j)) - TP;

    if (TP + FN) > 0
        recall(j) = TP / (TP + FN);
    end

    if (TP + FP) > 0
        precision(j) = TP / (TP + FP);
    end

    if (precision(j) + recall(j)) > 0
        f1(j) = 2 * precision(j) * recall(j) / (precision(j) + recall(j));
    end
end
disp(cm);
end