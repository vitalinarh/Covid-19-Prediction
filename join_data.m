clear all;

%% Fetch imported data and convert types
% Load mat file:
load('data\PatientInfoNumeric.mat');
load('data\WeatherNumeric.mat');
load('data\RegionNumeric.mat');

%% Weather
PatientInfo = [PatientInfo(:, 1:end-1) NaN(height(PatientInfo), 7) PatientInfo(:, end)];

for i=1:height(PatientInfo)
    idx_provinces = find(Weather(:, 2) == PatientInfo(i, 5));
    idx_date = find(Weather(idx_provinces, 3) == PatientInfo(i, 11));
    
    if ~isempty(idx_date)
        PatientInfo(i, 14:20) = Weather(idx_provinces(idx_date), 4:end);
    end
end

%% Region
% Don't add latitude or longitude:
PatientInfo = [PatientInfo(:, 1:end-1) NaN(height(PatientInfo), 7) PatientInfo(:, end)];

for i=1:height(PatientInfo)
    idx_provinces = find(Region(:, 2) == PatientInfo(i, 5));
    idx_city = find(Region(idx_provinces, 3) == PatientInfo(i, 6));
    
    if ~isempty(idx_city)
        PatientInfo(i, 21:27) = Region(idx_provinces(idx_city), 6:end);
    end
end

save('data/PatientInfoAdditional.mat', 'PatientInfo');