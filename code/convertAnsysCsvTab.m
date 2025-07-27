% =================================================================================================
% ANSYS CSV to TAB Converter Script
% =================================================================================================
%
% Automatically handles W, mW, and kW units
%
% =================================================================================================
% (c) 2025, Hans Wouters, MIT Licence
% =================================================================================================


% Clear existing variables
clear;

% Define input files
coreLossFile = 'ITX_v5_Optimizer_CoreLoss.csv';
solidLossFile = 'ITX_v5_Optimizer_SolidLoss.csv';
outputFile = 'ITX_v5_Optimizer.tab';

% Initialize tables with unit conversion
coreTable = parseAnsysCsv(coreLossFile, 'Pfe', 'CoreLoss');
solidTable = parseAnsysCsv(solidLossFile, 'Pcu', 'SolidLoss');

% Merge tables (keeping all combinations)
if ~isempty(coreTable) && ~isempty(solidTable)
    mergedTable = outerjoin(coreTable, solidTable, 'Keys', {'x_t','y_t','y_c1','y_c2','z_c1'}, 'MergeKeys', true);
    
    % Write with explicit file type specification
    writetable(mergedTable, outputFile, 'Delimiter', '\t', 'FileType', 'text');
    
    fprintf('Successfully created: %s\n', outputFile);
else
    error('Failed to process CSV files');
end

function dataTable = parseAnsysCsv(filename, valueName, lossType)
    % Read CSV file
    try
        fid = fopen(filename, 'r');
        csvData = textscan(fid, '%q %f', 'Delimiter', ',');
        fclose(fid);
    catch
        error('Error reading file: %s', filename);
    end
    
    % Initialize variables
    numEntries = length(csvData{1});
    x_t = zeros(numEntries, 1);
    y_t = zeros(numEntries, 1);
    y_c1 = zeros(numEntries, 1);
    y_c2 = zeros(numEntries, 1);
    z_c1 = zeros(numEntries, 1);
    values = csvData{2};
    
    % Check for units and convert to Watts
    for i = 1:numEntries
        entry = csvData{1}{i};
        
        % Handle SolidLoss units
        if strcmp(lossType, 'SolidLoss')
            if contains(entry, 'SolidLoss [mW]')
                values(i) = values(i) * 1e-3; % mW to W
            elseif contains(entry, 'SolidLoss [kW]')
                values(i) = values(i) * 1e3; % kW to W
            end
        % Handle CoreLoss units    
        elseif strcmp(lossType, 'CoreLoss')
            if contains(entry, 'CoreLoss [mW]')
                values(i) = values(i) * 1e-3; % mW to W
            elseif contains(entry, 'CoreLoss [kW]')
                values(i) = values(i) * 1e3; % kW to W
            end
        end
    end
    
    % Process each entry
    for i = 1:numEntries
        entry = csvData{1}{i};
        
        % Extract parameters (order doesn't matter)
        x_t(i) = getParamValue(entry, 'x_t');
        y_t(i) = getParamValue(entry, 'y_t');
        y_c1(i) = getParamValue(entry, 'y_c1');
        y_c2(i) = getParamValue(entry, 'y_c2');
        z_c1(i) = getParamValue(entry, 'z_c1');
    end
    
    % Create output table
    dataTable = table(x_t, y_t, y_c1, y_c2, z_c1, values, ...
        'VariableNames', {'x_t', 'y_t', 'y_c1', 'y_c2', 'z_c1', valueName});
end

function value = getParamValue(str, paramName)
    % Extract parameter value from string
    pattern = [paramName '=''([\d.]+)mm'''];
    match = regexp(str, pattern, 'tokens');
    
    if ~isempty(match)
        value = str2double(match{1}{1});
    else
        value = NaN;
        warning('Parameter %s not found in: %s', paramName, str);
    end
end
