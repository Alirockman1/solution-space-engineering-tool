function save_files(~, ~, dataManager, hFigure)
% SAVE_FILES Saves plots and data to user-specified or default folder.
%   SAVE_FILES handles saving all individual plot axes as high-resolution
%   JPG images and exports design space data to an Excel file. If no folder
%   path is provided or the folder does not exist, it defaults to a
%   'SavedFiles' directory next to the current script.
%
%   INPUT:
%       ~, ~               - Unused input arguments for UI callback compatibility
%       dataManager        - Struct/class instance managing design data,
%                            plot handles, UI handles, and file naming
%       hFig               - Handle to the main figure (for displaying alerts)
%
%   OPERATION:
%       - Validates or sets default folder path for saving files
%       - Creates timestamped subfolder 'DesignSpacePlots_ddMM_HH' to organize saved files
%       - Saves each individual plot axis as a JPG with 300 dpi resolution
%       - Consolidates "Good" and "Bad" performance data points into a table
%       - Writes the data table to an Excel file named
%         'SelectiveDesignSpaceProjection_ddMM_HH.xlsx' (or custom name if provided)
%       - Displays confirmation or error alerts using `uialert`
%
%   OUTPUT:
%       None (files saved to disk, user alerted via GUI)
%
%   DEPENDENCIES:
%       - dataManager object with fields:
%           .PostTextHandles, .AxisHandles, .TextHandles, and update methods
%       - MATLAB R2019b or newer for exportgraphics and uialert functions
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    % Check if folderpath provided
    if isempty(dataManager.PostTextHandles(3).String)
        % Get the full path of the currently running script
        [currentScriptPath, ~, ~] = fileparts(mfilename('fullpath'));

        % Go one folder back and into 'SavedFiles'
        saveFolder = fullfile(currentScriptPath, '..', 'SavedFiles');

        % Ensure the folder exists
        if ~exist(saveFolder, 'dir')
            mkdir(saveFolder);
        end

        dataManager.PostTextHandles(3).String = saveFolder;                % Fall back to default script path
        uialert(hFigure, ...
                sprintf('Using default path:\n%s', currentScriptPath), ...
                'Folder Not Found', ...
                'Icon', 'warning');
    else
        % Use default path if the provided folder does not exist
        if ~isfolder(dataManager.PostTextHandles(3).String)
            % Get the full path of the currently running script
            [currentScriptPath, ~, ~] = fileparts(mfilename('fullpath'));
            dataManager.PostTextHandles(3).String = currentScriptPath;                                  % Fall back to default script path
            uialert(hFigure, ...
                    sprintf('Provided folder does not exist.\nUsing default path:\n%s', currentScriptPath), ...
                    'Folder Not Found', ...
                    'Icon', 'info');
        end

    end

    %% Save Figure
    timeStamp = datestr(datetime('now'), 'HHMM_ddmm');
    saveFolder = fullfile(dataManager.PostTextHandles(3).String,...
        ['DesignSpacePlots_' timeStamp]);

    if ~exist(saveFolder, 'dir')
        mkdir(saveFolder);
    end
    
    try
        % Loop through each axes and save it
        for axisIdx = 1:numel(dataManager.AxisHandles.IndividualPlots)
            axesHandle = dataManager.AxisHandles.IndividualPlots(axisIdx);
        
            % Clean axis labels for file name (remove spaces/special chars)
            xLabel = matlab.lang.makeValidName(axesHandle.XLabel.String);
            yLabel = matlab.lang.makeValidName(axesHandle.YLabel.String);
        
            % Create filename: e.g. plot_axis_xPressure_yTemperature.jpg
            fileName = sprintf('plot_axis_x%s_x%s.jpg', xLabel, yLabel);
        
            % Full path to save
            savePathFull = fullfile(saveFolder, fileName);
        
            % Save the individual axes content as JPG with 300 dpi
            exportgraphics(axesHandle, savePathFull, 'Resolution', 300);
        end
        
        % Show confirmation alert
        uialert(hFigure, ...
            sprintf('Main figure saved as:\n%s', fileName), ...
            'Figure Saved', ...
            'Icon', 'success');
    catch
        uialert(hFigure, ...
            sprintf('Failed to save images to:\n%s', fileName), ...
            'Folder Not Found', ...
            'Icon', 'error');

    end
    
    %% Save Data
    % Determine the Excel file name inside the timestamped folder
    if isempty(dataManager.PostTextHandles(1).String)
        fileName = ['SelectiveDesignSpaceProjection_' timeStamp '.xlsx'];
    else
        fileName = [dataManager.PostTextHandles(1).String, '.xlsx'];
    end
    outputFilePath = fullfile(saveFolder, fileName);

    variableName = cell(1, numel(dataManager.Labels));
    
    for i = 1:numel(dataManager.Labels)
        variableName{i} = dataManager.Labels(i).varname;
    end
    
    try
        % Convert to table
        if isnumeric(dataManager.EvaluationData.DesignSample)
            sampleTable = array2table([dataManager.EvaluationData.DesignSample,...
                dataManager.EvaluationData.PerformanceDeficit]);
        else
            sampleTable = dataManager.EvaluationData.DesignSample;
        end
    
        % Assign proper column names
        sampleTable.Properties.VariableNames(1:numel(variableName)) = variableName;
        sampleTable.Properties.VariableNames{numel(variableName) + 1} = 'Performance Deficit';
    
        % Logic: any value ≤ 0 in the row → 'Good', else 'Bad'
        labels = repmat("Bad", size(sampleTable,1), 1);
        mask = any(table2array(sampleTable(:, variableName)) <= 0, 2);
        labels(mask) = "Good";
    
        % Add status column
        sampleTable.Classification = labels;

        % Write the table to Excel
        writetable(sampleTable, outputFilePath, 'Sheet', 'Results', 'WriteRowNames', true);

        % Save the struct EvaluationData to the .mat file
        matFilePath = fullfile(saveFolder, 'EvaluationData.mat');
        EvaluationData = dataManager.EvaluationData;
        save(matFilePath, 'EvaluationData', '-v7.3');                      % save to correct file path

        % Show confirmation alert
        uialert(hFigure, ...
            sprintf('Data written to Excel:\n%s', fileName), ...
            'Figure Saved', ...
            'Icon', 'success');

    catch
        uialert(hFigure, ...
            sprintf('Failed to write data to Excel:\n%s', fileName), ...
            'Folder Not Found', ...
            'Icon', 'error');
    end
end