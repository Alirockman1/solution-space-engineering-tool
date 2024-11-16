%% Code to create a solution space with user defined Design Variables and problem statement
%
%   > A valid excel file containing Design variable space, constant parameters, quantities of interest
%       limits needs to be specified.
%	> The problem statement is user defined from available options.
%   > Requirements for the script:
%       1. MATLAB version R2018b or higher.
%       2. Successfully installed Image Processing Toolbox.

%% Setting up the environment
clear all
close all

currentFile = matlab.desktop.editor.getActiveFilename;  % Get the full path of the active file
addpath(fileparts(currentFile));  % Add the folder containing the active file to the path

% Add all relevent folders and subfolders to the MATLAB path
addpath(genpath("E:\My Folder\Ali Documents\Job Documents\Hiwi\Hiwi - LPL - Eduardo"));

%% Compatability check %%

% List all enteries in Design Problems folder
cd("E:\My Folder\Ali Documents\Job Documents\Hiwi\Hiwi - LPL - Eduardo\xray-matlab\v11\XRay\Data\Design_Problems")
problems=dir;
problems=problems([problems.isdir]==0);
entries = cell(1,length(problems));

% Check correct version of MATLAB
% Retrieve version
v = version;
pos = strfind(v,'R');
v = v(pos:pos+5);

jear = str2double(v(2:5));
releas = v(end);

if ~(jear >= 2019 || (jear == 2018 && releas == 'b'))
    error('Your current MATLAB version is not capable of running this version of the programm.\n%s',...
        'Please use MATLAB R2018b or newer versions of MATLAB or consider using an older version of the SSE-program.')
end

% Check if Image Processing Toolbox is installed
v = ver;
for i=1:length(v)
    if strcmp(v(i).Name,'Image Processing Toolbox')
        installed = 1;
        break
    else
        installed = 0;
    end
end

if ~installed
    
    error('Image Processing Toolbox is not installed.\n%s',...
        'Please install the required toolbox or consider using an older version of the SSE-program.')
end

%% Parse the excel file %%
% x: struct containing details pertaining to the design variable
% param: struct containing details pertaining to the design parameters (constants)
% qoi: struct containing QoI and specified constraints
% plotdes:  struct containing desired combination of Design variables
% extraopt: Additional information for plotting solution space

% excel file to open using the parser
excel_file = input('Please enter the name of the excel data file: ','s');
excel_file = [excel_file '.xlsx'];

try
    [x,param,qoi,lbl,plotdes,extraopt] = excelParserXRayTool(excel_file)
catch
    warning('Incorrect excel file specified. Please check the file location or name');
end


%% Function Call %%

% Provide all available function calls
% Define the folder path (update the path as per your needs)
folderPath = 'E:\My Folder\Ali Documents\Job Documents\Hiwi\Hiwi - LPL - Eduardo\xray-matlab\v11\Merging\Systems';

% Get all .m files in the folder
mFiles = dir(fullfile(folderPath, '*.m'));

% Check if the folder contains any .m files
if isempty(mFiles)
    disp('No MATLAB (.m) files found in the specified folder.');
else
    % Print the names of all .m files with numbering
    disp('The available list of functions are:');
    for i = 1:length(mFiles)
        % Remove the .m extension and display the numbered function name
        [~, functionName, ~] = fileparts(mFiles(i).name);
        fprintf('%d. %s\n', i, functionName);
    end
    
    % Prompt the user to input the number of the function they want to select
    selectedNumber = input('Please enter the number of the function you want to select: ');
    
    % Ensure the input is valid
    if selectedNumber >= 1 && selectedNumber <= length(mFiles)
        selectedFunction = mFiles(selectedNumber).name(1:end-2); % Get function name without extension
        fprintf('You have selected function: %s\n', selectedFunction);
    else
        disp('Invalid selection. Please enter a valid number.');
    end
end

%% Bottom up Mapping
% Required: Functioncall and Design Variables

selectedFunction = str2func(mFiles(selectedNumber).name(1:end-2)); % Create a function handle directly
bottomUpMapping = BottomUpMappingFunction(selectedFunction,[param.value]);

%% Design Evaluator
% Required: BottomupMapping and design space limits

designEvaluator = DesignEvaluatorBottomUpMapping(bottomUpMapping,...
    qoi.crll,qoi.crul);

%% Box-shaped Design Space
% Option 1: The initial design is specified and a stochastic optimized box created
% Option 2: Both upper and lower values are provided for the design variables and a box created

if all(~isnan([x.dinit]))
initialDesign = [x.dinit];  % QUESTION: WHERE TO ADD THIS BOX?

options = sso_stochastic_options('box','SamplingMethodFunction',@sampling_random);

[designBox,problemData,iterData] = sso_box_stochastic(...
    designEvaluator,...
    initialDesign,...
    [x.dslb],...
    [x.dsub],...
    options);
else
    designBox = [[x.sblb]/2;[x.sbub]/2];
end

%% Selective Design Space Projection
% desired plots by design variable index
plotTiles = [1,size(plotdes, 2)]; % 2 rows, 3 columns of subplots

for i = 1:size(plotdes, 2)
    desiredPlots(i, :) = [plotdes(i).axdes{1}, plotdes(i).axdes{2}];  % Fill in the rows
    axisLabel{i} = lbl(i).dispname;  % Store each name in the cell array 
end

[h,PlotData] = plot_selective_design_space_projection(...
    designEvaluator,...
    designBox,...
    [x.dslb],...
    [x.dsub],...
    desiredPlots,...
    plotTiles,...
    'NumberSamplesPerPlot',str2num(extraopt.SampleSize),...
    'AxesLabels',axisLabel,...
    'MarkerColorsViolatedRequirements','r',...
    'PlotOptionsBad',{'Marker','x'});
%'PlotOptionsBad',{'Marker', extraopt.SampleMarkerType, 'MarkerSize', str2num(extraopt.SampleMarkerSize), 'LineWidth', str2num(extraopt.SolSpLineWidth), 'LineStyle', extraopt.SolSpLineType});

legend([h.GoodPerformance,h.BadPerformance],...
    {'Good Designs','Violate Distance Requirement'});
sgtitle('3D Sphere - Box Decomposition');

%% Save the Figure and Data points

% User input for saving the figure
saveOption = input('Do you want to save the figure (y|n): ', 's');
if strcmpi(saveOption, 'y')
    saveFolder = input('Provide folder (with path) to save: ', 's');
    
    % Check if the provided folder exists, if not create it
    if ~isfolder(saveFolder)
        mkdir(saveFolder);
        fprintf('Folder did not exist, so it was created: %s\n', saveFolder);
    end
    
    % Save the Figure
    save_print_figure(h.MainFigure, fullfile(saveFolder, 'SelectiveDesignSpaceProjection'));
    fprintf('Figure saved to folder: %s\n', saveFolder);
    
    % Save the Data Points to Excel
    outputFilePath = fullfile(saveFolder, excel_file);  % Save in the same folder
    
    try
        % Assume PlotData contains good and bad performance data points
        goodX = h.GoodPerformance.XData;
        goodY = h.GoodPerformance.YData;
        goodClass = repmat("Good", size(goodY));  % Classification for good data

        badX  = h.BadPerformance.XData;
        badY  = h.BadPerformance.YData;
        badClass = repmat("Bad", size(badY));    % Classification for bad data

        % Combine the data points and classifications
        % Create a table to hold all data
        combinedY = vertcat(goodY', badY');  % Concatenate Y values
        combinedX = vertcat(goodX', badX');  % Concatenate X values
        combinedClass =vertcat(goodClass', badClass');  % Concatenate classifications
        
        % Create a final table
        finalTable = table(combinedY, combinedX, combinedClass, ...
                           'VariableNames', {'YValues', 'XValues', 'Classification'});

        writetable(finalTable, outputFilePath, 'Sheet', 'Results', 'WriteRowNames', true);
        fprintf('Data points saved to %s\n', outputFilePath);
    catch ME
        warning('Failed to write data to Excel: %s', ME.message);
    end
    
else
    disp('Figure and data not saved.');
end

clear h;  % Clear figure handle if needed