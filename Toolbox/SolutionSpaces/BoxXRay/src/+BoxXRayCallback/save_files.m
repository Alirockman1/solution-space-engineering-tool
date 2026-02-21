function save_files(src, event, dataManager, hFigure)
%SAVE_FILES Save plots and evaluation data to files
%   SAVE_FILES saves all individual plot axes as high-resolution JPG images
%   and exports evaluation data to Excel and MAT files. The function creates
%   a timestamped subfolder and saves all results there. If no save path is
%   provided or the folder doesn't exist, it defaults to a 'RESULTS/XRay/'
%   directory.
%
%   SAVE_FILES(SRC, EVENT, DATAMANAGER, HFIGURE) is called when the user
%   clicks the "Save Figure and Data" button. It saves plots, Excel data,
%   and MAT files to the specified or default folder.
%
%   Inputs:
%       - SRC : uibutton
%           -- handle to the button that triggered the callback (unused)
%       - EVENT : event data
%           -- event data from button callback (unused)
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing plot axes handles, evaluation data,
%           and save path textbox handle
%       - HFIGURE : Figure
%           -- handle to the main figure for displaying alerts
%
%   Outputs:
%       None (files are saved to disk, user is alerted via GUI)
%
%   Files Saved:
%       - Individual plot images: plot_axis_x-{xLabel}_y-{yLabel}.jpg (300 dpi)
%       - Excel file: XRayData.xlsx with design samples and QOI values
%       - MAT files: Data.mat with:
%           -- Plot data
%           -- Evaluation data
%           -- Optimization data
%           -- Box bounds
%           -- Design space
%           -- Quantities of interest limits
%
%   See also exportgraphics, writetable, uialert.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2025.
%   Copyright 2025 Eduardo Rodrigues Della Noce (Author)
%   Copyright 2025 Ali Abbas Kapadia (Author)
%   SPDX-License-Identifier: Apache-2.0

%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
% 
%       http://www.apache.org/licenses/LICENSE-2.0
% 
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.

    currentWorkingDirectory = pwd;
    defaultSaveFolder = fullfile([currentWorkingDirectory,'/RESULTS/XRay/']);

    % Check if folderpath provided
    if (isempty(dataManager.TextboxSavePathHandle.Value) || ~isfolder(dataManager.TextboxSavePathHandle.Value))
        % Get the full path of the currently running script
        % Ensure the folder exists
        if ~exist(defaultSaveFolder, 'dir')
            mkdir(defaultSaveFolder);
        end

        dataManager.TextboxSavePathHandle.Value = defaultSaveFolder;
        uialert(hFigure, ...
                sprintf('Using default path:\n%s', defaultSaveFolder), ...
                'Folder Not Found', ...
                'Icon', 'warning');
    end

    %% Save Figure
    timeStamp = get_date_time;
    saveFolder = fullfile([dataManager.TextboxSavePathHandle.Value,timeStamp,'/']);

    if ~exist(saveFolder, 'dir')
        mkdir(saveFolder);
    end
    
    try
        % Loop through each axes and save it
        for axisIdx = 1:numel(dataManager.PlotAxesHandles)
            axesHandle = dataManager.PlotAxesHandles(axisIdx);
        
            % Clean axis labels for file name (remove spaces/special chars)
            xLabel = matlab.lang.makeValidName(axesHandle.XLabel.String);
            yLabel = matlab.lang.makeValidName(axesHandle.YLabel.String);
        
            % Create filename: e.g. plot_axis_xPressure_yTemperature.jpg
            fileName = sprintf('plot_axis_x-%s_y-%s.jpg', xLabel, yLabel);
        
            % Full path to save
            savePathFull = fullfile(saveFolder, fileName);
        
            % Save the individual axes content as JPG with 300 dpi
            exportgraphics(axesHandle, savePathFull, 'Resolution', 300);
        end
        
        % Show confirmation alert
        uialert(hFigure, ...
            sprintf('Individual plots saved to:\n%s', saveFolder), ...
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
    outputFilePath = fullfile(saveFolder, 'XRayData.xlsx');

    variableName = dataManager.get_design_variable_names;
    quantityOfInterestName = dataManager.get_quantities_of_interest_names;
    try
        % Convert to table
        tableData = dataManager.EvaluationData.DesignSample;
        if(~isempty(dataManager.EvaluationData.PerformanceMeasure))
            tableData = [tableData, dataManager.EvaluationData.PerformanceMeasure];
        else
            tableData = [tableData, dataManager.EvaluationData.PerformanceDeficit];
        end
        sampleTable = array2table(tableData);
    
        % Assign proper column names
        sampleTable.Properties.VariableNames(1:numel(variableName)) = variableName;
        sampleTable.Properties.VariableNames((numel(variableName)+1):(numel(variableName)+numel(quantityOfInterestName))) = quantityOfInterestName;
    
        % Add status column
        isGoodPerformance = dataManager.EvaluationData.IsGoodPerformance;
        labels = repmat("Bad", size(sampleTable,1), 1);
        labels(isGoodPerformance) = "Good";
        sampleTable.Classification = labels;

        % Write the table to Excel
        writetable(sampleTable, outputFilePath, 'Sheet', 'Results', 'WriteRowNames', true);
        % Show confirmation alert
        uialert(hFigure, ...
            sprintf('Data written to Excel:\n%s', outputFilePath), ...
            'Figure Saved', ...
            'Icon', 'success');

    catch
        uialert(hFigure, ...
            sprintf('Failed to write data to Excel:\n%s', fileName), ...
            'Folder Not Found', ...
            'Icon', 'error');
    end

    % Save complete raw data
    try
        % Save all data to the .mat file
        matFilePath = fullfile(saveFolder, 'Data.mat');
        PlotData = dataManager.PlotData;
        EvaluationData = dataManager.EvaluationData;
        OptimizationData = dataManager.OptimizationData;
        BoxBounds = dataManager.get_design_box;
        DesignSpace = dataManager.get_design_space;
        QuantitiesOfInterestLimits = dataManager.get_quantities_of_interest_limits;
        save(matFilePath, ...
            'PlotData', ...
            'EvaluationData', ...
            'OptimizationData', ...
            'BoxBounds', ...
            'DesignSpace', ...
            'QuantitiesOfInterestLimits', ...
            '-v7.3'); % save to correct file path
        clear PlotData EvaluationData OptimizationData BoxBounds DesignSpace QuantitiesOfInterestLimits;

        uialert(hFigure, ...
            sprintf('Saving data completed to:\n%s', saveFolder), ...
            'Data Saved', ...
            'Icon', 'success');
    catch
        uialert(hFigure, ...
            sprintf('Failed to save data to .mat files:\n%s', matFilePath), ...
            'Folder Not Found', ...
            'Icon', 'error');
    end
end