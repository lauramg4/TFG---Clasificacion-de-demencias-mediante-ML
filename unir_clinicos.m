function [DATA, subject_ids] = unir_clinicos(power_rel, power_abs, archivo_excel)

T = readtable(archivo_excel);

Gender = zeros(height(T),1);
Gender(strcmp(T.Gender,'M')) = 1;

Age  = T.Age;
MMSE = T.MMSE;

Extra = [Gender Age MMSE];
EEG   = [power_rel power_abs];

DATA = [EEG Extra];

% sujetos
subject_ids = string(T.participant_id);

end