%% Setting up the environment
clear all;
close all;
warning('off', 'all');  % Turn back off after debugging

currentFile = matlab.desktop.editor.getActiveFilename;                     % Get the full path of the active file
runfileLocation = fileparts(currentFile);   

% Dynamically get the parent folder
[projectRoot, ~, ~] = fileparts(runfileLocation);

%% Parse the excel file %%
parseValues = excel_file_parser(projectRoot,'ExcelFile','ProblemDefinition'); % Extract excel values

%% Problem selection %%
selectedFunction = @car_crash_5d;

%% Create data manager
dataManager = SolutionSpaceData(parseValues.DesignVariable,...
    parseValues.QuantatiesOfInterest,parseValues.DesignParameters,...
    parseValues.Labels, parseValues.PlotDesigns,...
    parseValues.ExtraOptions, selectedFunction);

dataManager.selectedFunction = selectedFunction;

%% Create GUI
create_solution_space_GUI(dataManager);











