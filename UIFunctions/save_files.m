%% Function to save the figure and data
function save_files(~, ~, dataManager, hFig)

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
                    'Icon', 'warning');
        end

    end

    %% Save Figure
    % Generate a unique filename using timestamp
    if isempty(dataManager.PostTextHandles(2).String)
        timestamp = datestr(now, 'ddmm_HHMM');
        fileName = ['SelectiveDesignSpaceProjection_' timestamp '.jpg'];
        savePathFull = fullfile(dataManager.PostTextHandles(3).String, fileName);
    else
        fileName = [dataManager.PostTextHandles(2).String, '.jpg'];
        savePathFull = fullfile(dataManager.PostTextHandles(3).String, fileName);
    end
    
    % Save the figure as JPG
    exportgraphics(dataManager.PlotHandles.MainFigure, savePathFull, 'Resolution', 300);
    
    % Show confirmation alert
    uialert(hFig, ...
        sprintf('Main figure saved as:\n%s', fileName), ...
        'Figure Saved', ...
        'Icon', 'success');
    
    %% Save Data
    % Determine the Excel file name
    if isempty(dataManager.PostTextHandles(1).String)
        timestamp = datestr(now, 'ddmm_HHMM');
        fileName = ['SelectiveDesignSpaceProjection_' timestamp '.xlsx'];
        outputFilePath = fullfile(dataManager.PostTextHandles(3).String, ...
            fileName);  
    else
        fileName = [dataManager.PostTextHandles(1).String, '.xlsx'];
        outputFilePath = fullfile(dataManager.PostTextHandles(3).String, ...
            fileName);                                                     % Save as default name
    end

    try
        % Gather good and bad performance data points
        goodX = dataManager.PlotHandles.GoodPerformance.XData;
        goodY = dataManager.PlotHandles.GoodPerformance.YData;
        goodClass = repmat("Good", size(goodY));  % Classification for good data

        badX  = dataManager.PlotHandles.BadPerformance.XData;
        badY  = dataManager.PlotHandles.BadPerformance.YData;
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
            sprintf('Data writen to Excel:\n%s', fileName), ...
            'Figure Saved', ...
            'Icon', 'success');
    
    catch
        uialert(hFig, ...
            sprintf('Failed to write data to Excel:\n%s', fileName), ...
            'Folder Not Found', ...
            'Icon', 'warning');
    end
end