clear all
%% Fetch imported data and convert types
% Load mat file:
load('data\WeatherNumeric.mat');
load('data\PatientInfoNumeric.mat');

PatientInfo = [PatientInfo(:, 1 : end - 1) NaN(height(PatientInfo), 7) PatientInfo(:, end)];

%%
for i=1:height(PatientInfo)
    idx_provinces = find(Weather(:, 2) == PatientInfo(i, 5));
    idx_date = find(Weather(idx_provinces, 3) == PatientInfo(i, 11));
    if ~isempty(idx_date)
        PatientInfo(i, 14:20) = Weather(idx_provinces(idx_date), 4:end);
    end
end