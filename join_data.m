function [] = join_data()

clear all;

%% Fetch imported data and convert types
% Load mat file:
load('data\PatientInfoFilled.mat');
load('data\WeatherFilled.mat');
load('data\RegionFilled.mat');

%% Weather
PatientInfo = [PatientInfo(:, 1:end-1) NaN(height(PatientInfo), 7) PatientInfo(:, end)];

max_date = max(Weather(:, 3));

for i=1:height(PatientInfo)
    idx_provinces = find(Weather(:, 2) == PatientInfo(i, 5));
    
    if isempty(idx_provinces)
        PatientInfo(i, 14:20) = 0;
    end
    
    conf_date = PatientInfo(i, 11);
    
    if PatientInfo(i, 11) > max_date
        conf_date = max_date;
    end
    
    idx_date = find(Weather(idx_provinces, 3) == conf_date);
    
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
    else
        PatientInfo(i, 21:27) = mean(Region(idx_provinces, 6:end));
    end
end

PatientInfo(:, [21:23, 27]) = round(PatientInfo(:, [21:23, 27]));

save('data/PatientInfoAdditional.mat', 'PatientInfo');