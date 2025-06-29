function save_files(~, ~, dataManager, hFig)
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
        uialert(hFig, ...
                sprintf('Using default path:\n%s', currentScriptPath), ...
                'Folder Not Found', ...
                'Icon', 'warning');
    else
        % Use default path if the provided folder does not exist
        if ~isfolder(dataManager.PostTextHandles(3).String)
            % Get the full path of the currently running script
            [currentScriptPath, ~, ~] = fileparts(mfilename('fullpath'));
            dataManager.PostTextHandles(3).String = currentScriptPath;                                  % Fall back to default script path
            uialert(hFig, ...
                    sprintf('Provided folder does not exist.\nUsing default path:\n%s', currentScriptPath), ...
                    'Folder Not Found', ...
                    'Icon', 'info');
        end

    end

    %% Save Figure
    timeStamp = datetime('now', 'Format', 'ddMM_HH');
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
        uialert(hFig, ...
            sprintf('Main figure saved as:\n%s', fileName), ...
            'Figure Saved', ...
            'Icon', 'success');
    catch
        uialert(hFig, ...
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
    
    try
        % Gather good and bad performance data points
        goodX = dataManager.AxisHandles.GoodPerformance.XData;
        goodY = dataManager.AxisHandles.GoodPerformance.YData;
        goodClass = repmat("Good", size(goodY));  % Classification for good data

        badX  = dataManager.AxisHandles.BadPerformance.XData;
        badY  = dataManager.AxisHandles.BadPerformance.YData;
        badClass = repmat("Bad", size(badY));    % Classification for bad data

        % Combine the data points and classifications into a table
        combinedY = vertcat(goodY', badY');  % Concatenate Y values
        combinedX = vertcat(goodX', badX');  % Concatenate X values
        combinedClass = vertcat(goodClass', badClass');  % Concatenate classifications

        % Create the final table
        finalTable = table(combinedY, combinedX, combinedClass, ...
                           'VariableNames', {'YValues', 'XValues', 'Classification'});

        % Write the table to Excel
        writetable(finalTable, outputFilePath, 'Sheet', 'Results', 'WriteRowNames', true);

        % Show confirmation alert
        uialert(hFig, ...
            sprintf('Data written to Excel:\n%s', fileName), ...
            'Figure Saved', ...
            'Icon', 'success');

    catch
        uialert(hFig, ...
            sprintf('Failed to write data to Excel:\n%s', fileName), ...
            'Folder Not Found', ...
            'Icon', 'error');
    end
end