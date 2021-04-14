clear all;
close all;

%% Read and convert data, and create data structure.

% Read csv file:
csv_data = readtable('Data\PatientInfo.csv');

% Convert ages to numbers:
for i = 1:1:size(csv_data,1)
    age = csv_data.age{i};
    
    if ~strcmp(age,'')
        csv_data.age{i} = age(1:end-1);
    end
end

csv_data.age = str2double(csv_data.age);

% Convert text data to categories:
[csv_data.sex, classes_sex] = grp2idx(csv_data.sex);
[csv_data.country, classes_country] = grp2idx(csv_data.country);
[csv_data.province, classes_province] = grp2idx(csv_data.province);
[csv_data.city, classes_city] = grp2idx(csv_data.city);
[csv_data.infection_case, classes_infection] = grp2idx(csv_data.infection_case);
[csv_data.state, classes_state] = grp2idx(csv_data.state);

% Convert date/time data to numeric data:
csv_data.symptom_onset_date = datenum(csv_data.symptom_onset_date);
csv_data.confirmed_date = datenum(csv_data.confirmed_date);
csv_data.released_date = datenum(csv_data.released_date);
csv_data.deceased_date = datenum(csv_data.deceased_date);

% Get data matrix:
csv_data = table2array(csv_data);

% Create data structure:
data.X = csv_data(:,1:end-1)';
data.y = csv_data(:,end)';
data.dim = size(data.X,1);
data.num_data = size(data.X,2);
data.name = 'Covid-19 Data';

for i = 1:1:size(data.X,1)
    data.X(i,:) = fillmissing(data.X(i,:),'linear');
end

% Scale data:
data_scaled = scalestd(data);
