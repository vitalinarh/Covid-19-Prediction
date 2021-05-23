function [] = preprocess_data()

import_data();
convert_data();
fill_missing_data();
join_data();

load('data\PatientInfoFilled.mat');

% Save complete dataset with class diferentiation (Released vs. Others):
ind = find(PatientInfo(:,end) == 3);
PatientInfo(ind,end) = 1;
PatientInfo(setdiff(1:end,ind),end) = 2;

save('data\DataComplete_A.mat', 'PatientInfo');

load('data\PatientInfoAdditional.mat');

% Save complete dataset with the three classes:
save('data\DataComplete_C.mat', 'PatientInfo');

% Save complete dataset with class diferentiation (Deceased vs. Others):
ind = find(PatientInfo(:,end) == 1);
PatientInfo(setdiff(1:end,ind),end) = 2;

save('data\DataComplete_B.mat', 'PatientInfo');