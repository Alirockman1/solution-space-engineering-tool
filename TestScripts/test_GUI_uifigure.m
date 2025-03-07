%% Setting up the environment
clear all;
close all;

% Global Variables
global textHandles sliderHandles h PlotData qoi x;

currentFile = matlab.desktop.editor.getActiveFilename;  % Get the full path of the active file
runfilelocation = fileparts(currentFile);

% Dynamically get the parent folder
[projectRoot, ~, ~] = fileparts(runfilelocation);

%% Parse the excel file %%
% x: struct containing details pertaining to the design variable
% param: struct containing details pertaining to the design parameters (constants)
% qoi: struct containing QoI and specified constraints
% plotdes:  struct containing desired combination of Design variables
% extraopt: Additional information for plotting solution space

% Add all relevant folders and subfolders to the MATLAB path dynamically
excelfilepath = fullfile(projectRoot, 'ProblemDefinition');

% excel file to open using the parser
excel_file = input('Please enter the name of the excel data file: ','s');
excel_file = fullfile(excelfilepath, [excel_file, '.xlsx']);

[x,param,qoi,lbl,plotdes,extraopt] = excelParserXRayTool(excel_file);

try
    [x,param,qoi,lbl,plotdes,extraopt] = excelParserXRayTool(excel_file);
catch
    warning('Incorrect excel file specified. Please check the file location or name');
end

%% Function Call %%

% Provide all available function calls
% Define the folder path for available functions (dynamically set)
folderPath = fullfile(projectRoot, 'Systems');

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

selectedFunction = str2func(mFiles(selectedNumber).name(1:end-2)); % Create a function handle directly

%% Evaluate the design parameters
designEvaluator = SolutionSpace(param, qoi, selectedFunction);

GUI(x,qoi,lbl,plotdes,extraopt,designEvaluator)



%% START OF ALL GUI RELATED FUNCTIONS
function GUI(x, qoi, lbl, plotdes, extraopt, designEvaluator)
    
    % Define Variables
    global x qoi textHandles sliderHandles h textHandles_qoi;

    %% Create GUI layout

    % Retrive Screen size
    screenSize = get(0, 'ScreenSize');

    % Define GUI Screen
    hFig = uifigure('Name', 'Solution Space GUI', 'NumberTitle', 'off');
    hFig.Position = [screenSize(1), screenSize(2)+10, screenSize(3), screenSize(4)-10]; % Set the figure to full screen
    hFig.WindowState = 'maximized';

    %% Prepare a GUI %%
    % Define Tabs to be added to the screen
    tabgp = uitabgroup('Parent', hFig, 'Units', 'normalized',...
                        'Position',[.020 .15 0.4 .8]);
    tab1 = uitab(tabgp,"Title","Design Variable");
    tab4 = uitab(tabgp,"Title","Quantaties of Interest");
    tab2 = uitab(tabgp,"Title","Values from Plot");
    tab3 = uitab(tabgp,"Title","PostProcessing");

    %% 1. Tab for Design variables %%
    % Create a main panel for the sliders and inputs
    mainPanel = uipanel('Parent', tab1, 'Title', 'Design Variables', ...
                        'Units', 'normalized',...
                        'Position', [0.025 0.025 0.95 0.95]);

    % Sliders and textboxes for each design variable
    nVars = length(x);  % Number of design variables
    sliderHandles = gobjects(nVars, 2);  % Store slider handles for lower and upper bounds
    textHandles = gobjects(nVars, 2);    % Store text box handles for lower and upper values

    % Calculate the panel height for each variable
    panelHeight = 1/nVars;  % Equal distribution of space
    tabPosition = mainPanel.Parent(1).Position; % get width based on tab
    panelPixelWidth = tabPosition(3);
    panelPixelHeight = tabPosition(4)*panelHeight;

    for i = 1:nVars
        % Create a panel for each variable
        variablePanel = uipanel('Parent', mainPanel, 'Title', lbl(i).dispname, ...
                                'Units', 'normalized', ...
                                'Position', [0.02, 1 - i*panelHeight, 0.96, panelHeight-0.02]);

        % Design Space Lower Bound (leftmost)
        designSpaceHandles(i, 1) = uicontrol('Parent', variablePanel, 'Style', 'edit', ...
                                         'String', num2str(x(i).dslb, '%.2f'), ...
                                         'Units', 'normalized', ...
                                         'Position', [0.02, 0.4, 0.08, 0.3], ...
                                         'FontSize', 9, 'ForegroundColor', 'red', ...
                                         'Callback', @(src, event) design_textbox_callback(src, i, 1));

        % Solution Space Lower Bound
        textHandles(i, 1) = uicontrol('Parent', variablePanel, 'Style', 'edit', ...
                                      'String', num2str(x(i).sblb, '%.2f'), ...
                                      'Units', 'normalized', ...
                                      'Position', [0.11, 0.4, 0.08, 0.3], ...
                                      'Callback', @(src, event) textbox_callback(i, 1));

        % Create the slider with adjusted position
        % get sizes
        sliderLeft = 0.20*panelPixelWidth;
        sliderBottom = 0.4*panelPixelHeight;
        sliderWidth = 0.5*panelPixelWidth;
        sliderHeight = 0.25*panelPixelHeight;
        sliderHandles(i) = uislider(variablePanel, ...
                                        'range', ...
                                        'Limits', [x(i).dslb x(i).dsub], ...
                                        'Value', [x(i).sblb x(i).sbub], ...
                                        'MinorTicks', [], ...
                                        'Position', [sliderLeft, sliderBottom, sliderWidth, sliderHeight],...
                                        'ValueChangedFcn', @(src, event) slider_callback(i));

        % Solution Space Upper Bound
        textHandles(i, 2) = uicontrol('Parent', variablePanel, 'Style', 'edit', ...
                                      'String', num2str(x(i).sbub, '%.2f'), ...
                                      'Units', 'normalized', ...
                                      'Position', [0.81, 0.4, 0.08, 0.3], ...
                                      'Callback', @(src, event) textbox_callback(i, 2));

        % Design Space Upper Bound (rightmost)
        designSpaceHandles(i, 2) = uicontrol('Parent', variablePanel, 'Style', 'edit', ...
                                         'String', num2str(x(i).dsub, '%.2f'), ...
                                         'Units', 'normalized', ...
                                         'Position', [0.90, 0.4, 0.08, 0.3], ...
                                         'FontSize', 9, 'ForegroundColor', 'red', ...
                                         'Callback', @(src, event) design_textbox_callback(src, i, 2));
    end

    %% 2. Tab for QoI %%
    QoItab = uipanel('Parent', tab4, 'Title', 'Quantaties of Interest', ...
                             'Units', 'normalized',...
                             'Position', [0.015 0.15 0.9 0.875]);

    % Sliders and textboxes for each design variable
    nQOI = length(qoi);  % Number of design variables
    chkHandles = gobjects(nQOI, 1);         % Store active status
    textHandles_qoi = gobjects(nQOI, 2);    % Store text box handles for lower and upper values

     % Calculate the panel height for each variable based on the number of variables
    panelHeight = 0.9 / nQOI;  % Adjust 0.9 for some space between the panels

    for i = 1:nQOI
        % Create a panel for each variable
        QOIPanel = uipanel('Parent', QoItab, 'Title', qoi(i).dispname, ...
                           'Units', 'normalized', ...
                           'Position', [0.05, 0.95 - i * panelHeight, 0.9, panelHeight]);
    
        % Label for 'InActive'
        uicontrol('Parent', QOIPanel, 'Style', 'text', 'String', 'InActive', ...
                  'Units', 'normalized', 'Position', [0.01, 0.65, 0.15, 0.3], ...
                  'HorizontalAlignment', 'center');
    
        % Checkbox for 'InActive'
        chkHandles(i) = uicontrol('Parent', QOIPanel, ...
                        'Style', 'checkbox', ...
                        'Units', 'normalized', ...
                        'Position', [0.07, 0.7, 0.08, 0.35], ...
                        'FontSize', 10, ...
                        'Callback', @(hObject, ~) toggle_textbox(hObject, i));
    
        % Label for 'Lower Bound'
        uicontrol('Parent', QOIPanel, 'Style', 'text', 'String', 'Lower Bound', ...
                  'Units', 'normalized', 'Position', [0.20, 0.65, 0.2, 0.3], ...
                  'HorizontalAlignment', 'center');
    
        % Label for 'Upper Bound'
        uicontrol('Parent', QOIPanel, 'Style', 'text', 'String', 'Upper Bound', ...
                  'Units', 'normalized', 'Position', [0.50, 0.65, 0.2, 0.3], ...
                  'HorizontalAlignment', 'center');
    
        % Textbox for the lower bound
        textHandles_qoi(i, 1) = uicontrol('Parent', QOIPanel, 'Style', 'edit', ...
                                          'String', num2str(qoi(i).crll, '%.2f'), ...
                                          'Units', 'normalized', ...
                                          'Position', [0.20, 0.815, 0.2, 0.075]); % Centered below 'Lower Bound'
    
        % Textbox for the upper bound
        textHandles_qoi(i, 2) = uicontrol('Parent', QOIPanel, 'Style', 'edit', ...
                                          'String', num2str(qoi(i).crul, '%.2f'), ...
                                          'Units', 'normalized', ...
                                          'Position', [0.50, 0.815, 0.2, 0.075]); % Centered below 'Upper Bound'
        
        % Label for 'Colour'
        uicontrol('Parent', QOIPanel, 'Style', 'text', 'String', 'Colour', ...
                  'Units', 'normalized', 'Position', [0.75, 0.65, 0.2, 0.3], ...
                  'HorizontalAlignment', 'center');

        % Define the normalized position for the color picker
        normalizedPos = [0.75, 0.580, 0.08, 0.05]; % [x, y, width, height]
        
        % Compute absolute position based on panel size
        panelPos = getpixelposition(QOIPanel); % Get the panel's position (normalized in mainFig)
        absPos = [(panelPos(1) + panelPos(3)) * normalizedPos(1), ... % X
                  (panelPos(2) + panelPos(4)) * normalizedPos(2), ... % Y
                  panelPos(3) * normalizedPos(3), ...              % Width
                  panelPos(4) * normalizedPos(4)];                % Height
        
        % Add the uicolorpicker with adjusted position
        colorPicker = uicolorpicker('Parent', QOIPanel, ...
                                    'Position', absPos, ...
                                    ValueChangedFcn=@(src,event) updateColor(src,i));
    end

    %% 3. Update QOI
    uicontrol('Parent', QoItab, 'Style', 'pushbutton', 'String', 'Update QOI Data', ...
              'Units', 'normalized', 'Position', [0.375, 0.035, 0.25, 0.08], ...
              'BackgroundColor', [0.94, 0.94, 0.94], ...
              'Callback', @(src, event) update_qoi_callback(nQOI));


    %% 4. Tab to display selected values dynamically (for nVars variables) %%
    selectionPanel = uipanel('Parent', tab2, 'Title', 'Selected Values from Plot', ...
                             'Units', 'normalized',...
                             'Position', [0.015 0.15 0.9 0.875]);

    % Create a dynamic display for each variable
    textAreas = gobjects(nVars+1, 1);  % Store text area handles
    for tA = 1:nVars
        % Labels for each design variable
        uicontrol('Parent', selectionPanel, 'Style', 'text', 'String', [lbl(tA).dispname ':'], ...
                  'Units', 'normalized', 'Position', [0.05, 1 - tA*0.15, 0.3, 0.1]);

        % Text areas for each variable to display selected value
        textAreas(tA) = uicontrol('Parent', selectionPanel, 'Style', 'edit', 'String', 'N/A', ...
                                 'Units', 'normalized', 'Position', [0.35, 1 - tA*0.15, 0.6, 0.1], ...
                                 'Enable', 'off');
    end

    % Labels for design variable
    for JA = 1:length(qoi.varname)
        uicontrol('Parent', selectionPanel, 'Style', 'text', 'String', qoi.varname(JA), ...
                  'Units', 'normalized', 'Position', [0.05, 1 - (tA+JA)*0.15, 0.3, 0.1]);
    
        % Text areas for design variable
        textAreas(tA+1) = uicontrol('Parent', selectionPanel, 'Style', 'edit', 'String', 'N/A', ...
                                 'Units', 'normalized', 'Position', [0.35, 1 - (tA+JA)*0.15, 0.6, 0.1], ...
                                 'Enable', 'off');
    end

    % 2. Add a Button to Select Data from the Plot
    uicontrol('Parent', selectionPanel, 'Style', 'pushbutton', 'String', 'Select Data from Plot', ...
              'Units', 'normalized', 'Position', [0.15, 1 - (tA+2.5)*0.15, 0.6, 0.1], ...
              'Callback', @(src, event) selectDataFromPlot(lbl,textAreas));

    %% 5. Tab to Create Post-processing Panel %%
    % Default names and paths for saving if user doesn't provide inputs
    defaultExcelName = 'default_results.xlsx';
    defaultFigureName = 'default_figure.png';
    defaultSavePath = 'E:\My Folder\Ali Documents\Job Documents\Hiwi\Hiwi - LPL - Eduardo\xray-matlab\v11\XRay'; % Update this to your preferred default path

    % Create the Post-processing Panel with relative position in the main figure
    postProcessingPanel = uipanel('Parent', tab3, 'Title', 'Post-processing', ...
                                  'Units', 'normalized',...
                                  'Position', [0.015, 0.55, 0.95, 0.4]);
    
    % Text box for Excel file name
    uicontrol('Parent', postProcessingPanel, 'Style', 'text', 'String', 'Excel File Name:', ...
        'Units', 'normalized', 'Position', [0.05, 0.8, 0.5, 0.1], 'HorizontalAlignment', 'left');
    excelNameEdit = uicontrol('Parent', postProcessingPanel, 'Style', 'edit', ...
        'Units', 'normalized', 'Position', [0.35, 0.8, 0.45, 0.1], 'String', defaultExcelName);
    
    % Text box for Figure file name
    uicontrol('Parent', postProcessingPanel, 'Style', 'text', 'String', 'Figure File Name:', ...
        'Units', 'normalized', 'Position', [0.05, 0.6, 0.5, 0.1], 'HorizontalAlignment', 'left');
    figureNameEdit = uicontrol('Parent', postProcessingPanel, 'Style', 'edit', ...
        'Units', 'normalized', 'Position', [0.35, 0.6, 0.45, 0.1], 'String', defaultFigureName);
    
    % Text box for Save Path
    uicontrol('Parent', postProcessingPanel, 'Style', 'text', 'String', 'Save Path:', ...
        'Units', 'normalized', 'Position', [0.05, 0.4, 0.5, 0.1], 'HorizontalAlignment', 'left');
    savePathEdit = uicontrol('Parent', postProcessingPanel, 'Style', 'edit', ...
        'Units', 'normalized', 'Position', [0.35, 0.4, 0.55, 0.1], 'String', defaultSavePath);
    
    % Save button at the bottom of the GUI
    uicontrol('Parent', postProcessingPanel, 'Style', 'pushbutton', 'String', 'Save Figure and Data', ...
        'Units', 'normalized', 'Position', [0.2, 0.1, 0.6, 0.15], 'Callback', @(src, event) saveFiles(src, event, ...
                                                             excelNameEdit.String, ... % Excel name from edit box
                                                             figureNameEdit.String, ... % Figure name from edit box
                                                             savePathEdit.String, ...   % Save path from edit box
                                                             defaultExcelName, ...      % Default Excel name
                                                             defaultFigureName, ...     % Default figure name
                                                             defaultSavePath, ...       % Default save path
                                                             h));
    
    %% 6. Update Plot button at the bottom of the GUI
    uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Update Plot', ...
              'Units', 'normalized', 'Position', [0.325, 0.035, 0.2, 0.08], ...
              'Callback', @(src, event) updatePlot(lbl,plotdes,extraopt,designEvaluator,nVars));
    
    %% 7. Rerun the Optimization
    uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Optimize', ...
              'Units', 'normalized', 'Position', [0.55, 0.035, 0.1, 0.08], ...
              'BackgroundColor', [0.94, 0.94, 0.94], ...
              'Callback', @(src, event) runOptimization(x, designEvaluator));

    %% 8. Plot
    % Create the figure box for placing figure
    figureBox = uipanel('Parent', hFig, 'Title', 'Solution Space', ...
                        'Units', 'normalized', ...
                        'Position', [0.45, 0.15, 0.50, 0.80]);
    
    % axes('Parent', hFig, 'Position', [0.20, 0.55, 0.9, 0.6]);
    axis off;  % Turn off axis for the figure box
    h = SolutionSpace_plot(lbl,plotdes,extraopt,designEvaluator);

    % nRows = 1; % FIX: read from table, plot
    % nCols = 3; % FIX: read from table, plot
    % totalCells = nRows * nCols;
    % solutionSpaceGrid =  uigridlayout(figureBox, [nRows,nCols]);
    % % Make all rows and columns have equal (flexible) size
    % solutionSpaceGrid.RowHeight = repmat({'1x'}, 1, nRows);
    % solutionSpaceGrid.ColumnWidth = repmat({'1x'}, 1, nCols);
    % nPlots = 3; % FIX: read from table, plot
    % for k = 1:totalCells
    %     currentAxis = uiaxes(solutionSpaceGrid);
    % end

end

%% Function: Run Optimization
function runOptimization(x, designEvaluator)
    global OptimdesignBox;
    % Change the button's appearance to indicate the process is running
    button = gcbo;
    originalColor = button.BackgroundColor; % Save original color
    button.BackgroundColor = [1, 0.8, 0.5]; % Set to light orange
    button.String = 'Running...';           % Update the button label
    drawnow; % Force UI update

    try
        % Run the optimization process
        OptimdesignBox = box_optimization(x, designEvaluator);
        
        % Provide feedback after the process completes
        msgbox('Optimization completed successfully!', 'Success', 'help');
    catch ME
        % Display an error message if the process fails
        errordlg(['An error occurred: ', ME.message], 'Error', 'modal');
    end

    % Restore the button's original appearance
    button.BackgroundColor = originalColor;
    button.String = 'Optimize';
    drawnow; % Force UI update
end

%% Function to update plot
function updatePlot(lbl,plotdes,extraopt,designEvaluator,nVars)
    global h textHandles x;
    % Get current slider values for bounds
    for i = 1:nVars
        lb = str2double(get(textHandles(i, 1), 'String'));
        ub = str2double(get(textHandles(i, 2), 'String'));
        
        % Update design space bounds in the main code logic (if necessary)
        x(i).sblb = lb;
        x(i).sbub = ub;
    end

    % Change the button's appearance to indicate the process is running
    button = gcbo;
    originalColor = button.BackgroundColor; % Save original color
    button.BackgroundColor = [1, 0.8, 0.5]; % Set to light orange
    button.String = 'Plotting Solution';           % Update the button label
    drawnow; % Force UI update

    try

        % Clear and plot the solution space based on new bounds
        h = SolutionSpace_plot(lbl,plotdes,extraopt,designEvaluator);

        % Provide feedback after the process completes
        msgbox('Solution Space Plot Completed!', 'Success', 'help');

    catch ME
        % Display an error message if the process fails
        errordlg(['An error occurred while plotting: ', ME.message], 'Error', 'modal');
    end

    % Restore the button's original appearance
    button.BackgroundColor = originalColor;
    button.String = 'Update Plot';
    drawnow; % Force UI update

end

%% Function to update text and boundaries based on slider
function slider_callback(varIndex)
    % Function to retrieve data from the slider.
    % The text boxes are updated 
    % The bounds in solution shape plots are updated [TO BE ADDED]

    global x sliderHandles textHandles;
    % disp(['Slider ', num2str(varIndex), ' moved.']);

    if ishandle(sliderHandles(varIndex))
        infoMatrix = get(sliderHandles(varIndex), 'Value');
        x(varIndex).sblb = round(infoMatrix(1,1),2);
        x(varIndex).sbub = round(infoMatrix(1,2),2);

        % Update text boxes with current slider values
        set(textHandles(varIndex, 1), 'String', num2str(x(varIndex).sblb));

        % Update text boxes with current slider values
        set(textHandles(varIndex, 2), 'String', num2str(x(varIndex).sbub));

    else
        disp('Invalid slider handle');
    end
  
    % Update Plot boundaries
    updateDesignVariableLines(varIndex, x)
end

%% Function to update sliders based on text input
function textbox_callback(varIndex, boundType)

    % Function to retrieve data from the slider.
    % The slider Position are updated 
    % The values are checked against the max and min 
    % The bounds in solution shape plots are updated [TO BE ADDED]

    global x textHandles sliderHandles;
    newValue = str2double(get(textHandles(varIndex, boundType), 'String'));

    % Check if the entered Value is within bounds
    if (boundType == 1 && newValue >= x(varIndex).dslb) % Check lower bounds
        x(varIndex).sblb = newValue;
        set(sliderHandles(varIndex), 'Value', [x(varIndex).sblb x(varIndex).sbub]);

    elseif boundType == 2 && newValue <= x(varIndex).dsub % Check upper bounds
        x(varIndex).sbub = newValue;
        set(sliderHandles(varIndex), 'Value', [x(varIndex).sblb x(varIndex).sbub]);
    else
        if boundType == 1
            set(textHandles(varIndex, 1), 'String', num2str(x(varIndex).dslb));
            set(sliderHandles(varIndex), 'Value', [x(varIndex).dslb x(varIndex).sbub]);
        elseif boundType == 2
            set(textHandles(varIndex, 2), 'String', num2str(x(varIndex).dsub));
            set(sliderHandles(varIndex), 'Value', [x(varIndex).sblb x(varIndex).dsub]);
        end

    end

    % Update Plot boundaries
    updateDesignVariableLines(varIndex, x)

end

%% Function to update design space based on input
function design_textbox_callback(src, varIndex, boundType)
    global x sliderHandles

    if boundType == 1
        x(varIndex).dslb = str2double(src.String);
    elseif boundType == 2
        x(varIndex).dsub = str2double(src.String);
    end

    set(sliderHandles(varIndex), 'Limits', [x(varIndex).dslb x(varIndex).dsub]);
    
end

%% Callback function to toggle text box enable state
function toggle_textbox(chk,i)
    global qoi
    if chk.Value % If checkbox is checked
        qoi(i).status = 'inactive';
    else ~chk.Value % If checkbox is notchecked
        qoi(i).status = 'active';
    end
end

%% Function to update the QOI
function update_qoi_callback(nQOI)
    global qoi textHandles_qoi
    
    for qoiIndex = 1:nQOI 
        if strcmp(qoi(qoiIndex).status, 'active')
            % Get new QOI limits
            qoi(qoiIndex).crll = str2double(get(textHandles_qoi(qoiIndex, 1), 'String'));
            qoi(qoiIndex).crul = str2double(get(textHandles_qoi(qoiIndex, 2), 'String'));
        else
            qoi(qoiIndex).crll = -inf;
            qoi(qoiIndex).crul = inf;
        end
    end

end

%% Function to save colour of QOI
function updateColor(src,i)
    global qoi

    qoi(i).color = [src.Value, zeros(1, 6)];
end

%% Function to save the figure and data
function saveFiles(~, ~, excelNameEdit, figureNameEdit, savePathEdit, ...
                   defaultExcelName, defaultFigureName, defaultSavePath, h)

    % Use default path if the provided folder does not exist
    if ~isfolder(savePathEdit)
        fprintf('Provided folder does not exist. Using default path: %s\n', defaultSavePath);
        savePathEdit = defaultSavePath;  % Fall back to default save path
    else
        fprintf('Using provided folder: %s\n', savePathEdit);
    end

    % Ensure the save directory exists
    if ~isfolder(savePathEdit)
        mkdir(savePathEdit);
        fprintf('Folder did not exist, so it was created: %s\n', savePathEdit);
    end
    
    % Save the main figure
    save_print_figure(h.MainFigure, fullfile(savePathEdit, 'SelectiveDesignSpaceProjection'));
    fprintf('Main figure saved to: %s\n', savePathEdit);
    
    % Determine the Excel file name
    if isempty(excelNameEdit)
        outputFilePath = fullfile(savePathEdit, defaultExcelName);  % Save as default name
    else
        outputFilePath = fullfile(savePathEdit, excelNameEdit);  % Save as provided name
    end
    
    try
        % Gather good and bad performance data points
        goodX = h.GoodPerformance.XData;
        goodY = h.GoodPerformance.YData;
        goodClass = repmat("Good", size(goodY));  % Classification for good data

        badX  = h.BadPerformance.XData;
        badY  = h.BadPerformance.YData;
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
        fprintf('Data points saved to: %s\n', outputFilePath);
    catch ME
        warning('Failed to write data to Excel: %s', ME.message);
    end

    % Save figure 2 as an image
    figHandle = findobj(0, 'Type', 'figure', 'Number', 2);
    if isempty(figHandle)
        warning('Figure 2 does not exist.');
    else
        if isempty(figureNameEdit)
            saveas(figHandle, fullfile(savePathEdit, defaultFigureName));  % Use default name
        else
            saveas(figHandle, fullfile(savePathEdit, figureNameEdit));  % Use provided name
        end
        fprintf('Figure 2 saved as: %s\n', fullfile(savePathEdit, figureNameEdit));
    end
end

%% Function to Select Data from the Plot and Display
function selectDataFromPlot(lbl,textAreas)
    global PlotData h;

    % Make figure 2 the current figure
    figure(2);

    % Get the selected point from the plot
    [xClick, yClick] = ginput(1); % Wait for the user to click on the plot

    currentAxes = gca; % Current axes
    selectedPlotTag = get(currentAxes, 'Tag'); % Retrieve the tag

    for i = 1:length(h.IndividualPlots)
        plotTag = sprintf('Plot%d', i);

        if strcmp(plotTag, selectedPlotTag) % Use strcmp for string comparison
            ax = h.IndividualPlots(i);
            xLabel = ax.XLabel.String; % Get the x-axis label
            yLabel = ax.YLabel.String; % Get the y-axis label

            % Retrieve variable numbers based on labels
            xVarNo = str2num(getVarNoFromLabel(lbl, xLabel));
            yVarNo = str2num(getVarNoFromLabel(lbl, yLabel));

            if isempty(xVarNo) || isempty(yVarNo)
                disp('Error: One or both variable numbers could not be found.');
                return;
            end

            % Extract the design samples for the current plot
            designSamples = PlotData(i).DesignSample;
            QOI = PlotData(i).EvaluatorOutput.PerformanceMeasure;
            feasibility = PlotData(i).EvaluatorOutput.PhysicalFeasibilityMeasure;

            % Get the selected design variable values
            selectedVars = [xClick, yClick];

            % Calculate the Euclidean distance from the selected point to all design samples
            distances = sqrt(sum((designSamples(:, xVarNo:yVarNo) - selectedVars).^2, 2));

            % Find the index of the closest point
            [~, closestIndex] = min(distances);
            closestPoint = designSamples(closestIndex, :);
            closestqoi   = QOI(closestIndex);
        end
    end

    % Update the text areas with the selected values
    for i = 1:length({lbl.dispname})
        textAreas(i).String = num2str(closestPoint(i), '%.4f');
    end

    for j = 1:length(closestqoi)
    textAreas(i+j).String = num2str(closestqoi, '%.4f');
    end
end

%% Map Variables to Variable Number
function varNo = getVarNoFromLabel(lbl, label)
    % This function searches for the label in dispname and returns the corresponding varno
    varNo = [];

    % Loop through dispname to find a match
    for i = 1:length({lbl.dispname})
        if strcmp(lbl(i).dispname, label)
            varNo = lbl(i).varno;
            return;  % Exit once the first match is found
        end
    end

    disp(['Label not found: ', label]);  % Display message if label not found
end

%% Function create the design evaluator
function designEvaluator = SolutionSpace(param, qoi, selectedFunction)

    %% Bottom up Mapping
    % Required: Functioncall and Design Variables
    bottomUpMapping = BottomUpMappingFunction(selectedFunction,[param.value]);
    
    %% Design Evaluator
    qoi.crll
    % Required: BottomupMapping and design space limits
    designEvaluator = DesignEvaluatorBottomUpMapping(bottomUpMapping,...
        qoi.crll,qoi.crul);
end


function OptimdesignBox = box_optimization(x, designEvaluator)
    
    %% Box-shaped Design Space
    % Option 1: The initial design is specified and a stochastic optimized box created
    % Option 2: Both upper and lower values are provided for the design variables and a box created
    
    initialDesign = [x.dinit];  % QUESTION: WHERE TO ADD THIS BOX?
    
    options = sso_stochastic_options('box','SamplingMethodFunction',@sampling_random);
    
    [designBox,problemData,iterData] = sso_box_stochastic(...
        designEvaluator,...
        initialDesign,...
        [x.dslb],...
        [x.dsub],...
        options);

    OptimdesignBox = designBox;

end

%% Selective Design Space Projection
function h = SolutionSpace_plot(lbl,plotdes,extraopt,designEvaluator)
    global PlotData OptimdesignBox x;

    % Close the already existing figure
    allFigures = findall(0, 'Type', 'figure');
    for i = 1:length(allFigures)
        if allFigures(i) == 2
            close(allFigures(i));  % Close the figure
        end
    end

    % desired plots by design variable index
    plotTiles = [1,size(plotdes, 2)]; % 2 rows, 3 columns of subplots

    % Determine the design box to use
    if (~isnan([x.dinit]))                    % Ensure design initialization is valid
        if isempty(OptimdesignBox)
            designBox = [[x.sblb]; [x.sbub]]; % Use the original design box
        else
            designBox = OptimdesignBox;       % Use the OptimdesignBox
        end
    else
        designBox = [[x.dslb]/2;[x.dsub]/2];
    end

    for i = 1:size(plotdes, 2)
        desiredPlots(i, :) = [plotdes(i).axdes{1}, plotdes(i).axdes{2}];  % Fill in the rows
        axisLabel{i} = lbl(i).dispname;  % Store each name in the cell array 
    end
    
    [h, ~, PlotData] = plot_selective_design_space_projection(...
        designEvaluator, ...
        designBox, ...
        [x.dslb], ...
        [x.dsub], ...
        desiredPlots, ...
        plotTiles, ...
        'NumberSamplesPerPlot', str2num(extraopt.SampleSize), ...
        'AxesLabels', axisLabel, ...
        'MarkerColorsViolatedRequirements', 'r', ...
        'PlotOptionsBad', {'Marker', 'x'}, ...
        'CurrentFigure', []);

    % Reset OptimdesignBox after the solution space has run
    OptimdesignBox = [];

    for i = 1:length(h.IndividualPlots)

        % Create dragable boundaries

        % Hold on to add draggable lines
        hold(h.IndividualPlots(i), 'on');

        % Extract variable indices for the current subplot
        xVarIndex = desiredPlots(i, 1); % X variable index
        yVarIndex = desiredPlots(i, 2); % Y variable index

        % Debugging output
        fprintf('Subplot %d: xVarIndex = %d, yVarIndex = %d\n', i, xVarIndex, yVarIndex);
 
        % Create vertical lines for the bounds
        vLineLower = line(h.IndividualPlots(i), [x(xVarIndex).sblb; x(xVarIndex).sblb], ...
        ylim(h.IndividualPlots(i)), 'Color', 'b', 'LineStyle', '--', ...
        'UserData', struct('type', 'left', 'index', xVarIndex), ...
        'Visible', 'on', 'HandleVisibility', 'on');
        vLineUpper = line(h.IndividualPlots(i), [x(xVarIndex).sbub; x(xVarIndex).sbub], ...
        ylim(h.IndividualPlots(i)), 'Color', 'b', 'LineStyle', '--', ...
        'UserData', struct('type', 'right', 'index', xVarIndex), ...
        'Visible', 'on', 'HandleVisibility', 'on');

        % Create horizontal lines for the bounds
        hLineLower = line(h.IndividualPlots(i), xlim(h.IndividualPlots(i)), ...
        [x(yVarIndex).sblb; x(yVarIndex).sblb], 'Color', 'b', ...
        'LineStyle', '--', 'UserData', struct('type', 'lower', 'index', yVarIndex), ...
        'Visible', 'on', 'HandleVisibility', 'on');
        hLineUpper = line(h.IndividualPlots(i), xlim(h.IndividualPlots(i)), ...
        [x(yVarIndex).sbub; x(yVarIndex).sbub], 'Color', 'b', ...
        'LineStyle', '--', 'UserData', struct('type', 'upper', 'index', yVarIndex), ...
        'Visible', 'on', 'HandleVisibility', 'on');

        % Set the ButtonDownFcn for dragging
        set([vLineLower, vLineUpper, hLineLower, hLineUpper], 'ButtonDownFcn', @startDragFcn);

        hold(h.IndividualPlots(i), 'off');
    end

    legend([h.GoodPerformance,h.BadPerformance],...
    {'Good Designs','Violate Distance Requirement'});
    sgtitle('3D Sphere - Box Decomposition');
end

%% Function to drag the boundaries
function startDragFcn(~, ~)
    global x textHandles sliderHandles;
    % Get the figure and current axes
    fig = gcf;
    if fig.Number ~= 2  % Check if the current figure is not Figure 2
        return;  % Exit the function if it's not Figure 2
    end

    currentAxes = gca; % Current axes

    % Set the WindowButtonMotionFcn to track movement
    set(fig, 'WindowButtonMotionFcn', @draggingFcn);
    set(fig, 'WindowButtonUpFcn', @stopDragFcn);

    % Store the current line handle
    lineHandle = gco; % Get the current object (the line)
    
    if ~strcmp(get(lineHandle, 'Type'), 'line')
        return;  % Exit if it's not a line
    end

    function draggingFcn(~, ~)
        % Get the current mouse position
        mousePos = get(currentAxes, 'CurrentPoint');
        xPos = mousePos(1, 1); % X coordinate of the mouse
        yPos = mousePos(1, 2); % Y coordinate of the mouse

        % Check which line is being dragged
        userData = get(lineHandle, 'UserData');
        switch userData.type
            case {'lower', 'upper'}
                % Update horizontal line (Y position)
                set(lineHandle, 'YData', [yPos yPos]);
            case {'left', 'right'}
                % Update vertical line (X position)
                set(lineHandle, 'XData', [xPos xPos]);
        end
    end

    function stopDragFcn(~, ~)
        % global x textHandles;
        % Get the current figure and axes
        fig = gcf;
        if fig.Number ~= 2
            return;  % Exit if it's not Figure 2
        end

        % Reset the motion and up functions
        set(fig, 'WindowButtonMotionFcn', '');
        set(fig, 'WindowButtonUpFcn', '');

        % Update the bounds based on the current position of the lines
        userData = get(lineHandle, 'UserData');
        index = userData.index; % Get the index of the variable

        switch userData.type
            case 'lower'
                newValue = get(lineHandle, 'YData');
                x(index).sblb = newValue(1); % Update lower bound for variable index
                set(textHandles(index, 1), 'String', num2str(x(index).sblb, '%.2f')); % Update text box
                set(sliderHandles(index), 'Value', [x(index).sblb x(index).sbub]);    % Update Slider
                fprintf('Updating bounds for index %d: %s = %.2f\n', index, userData.type, newValue(1));
            case 'upper'
                newValue = get(lineHandle, 'YData');
                x(index).sbub = newValue(1); % Update upper bound
                set(textHandles(index, 2), 'String', num2str(x(index).sbub, '%.2f')); % Update text box
                set(sliderHandles(index), 'Value', [x(index).sblb x(index).sbub]);    % Update Slider
                fprintf('Updating bounds for index %d: %s = %.2f\n', index, userData.type, newValue(1));
            case 'left'
                newValue = get(lineHandle, 'XData');
                x(index).sblb = newValue(1); % Update lower bound
                set(textHandles(index, 1), 'String', num2str(x(index).sblb, '%.2f')); % Update text box
                set(sliderHandles(index), 'Value', [x(index).sblb x(index).sbub]);    % Update Slider
                fprintf('Updating bounds for index %d: %s = %.2f\n', index, userData.type, newValue(1));
            case 'right'
                newValue = get(lineHandle, 'XData');
                x(index).sbub = newValue(1); % Update upper bound
                set(textHandles(index, 2), 'String', num2str(x(index).sbub, '%.2f')); % Update text box
                set(sliderHandles(index), 'Value', [x(index).sblb x(index).sbub]);    % Update Slider
                fprintf('Updating bounds for index %d: %s = %.2f\n', index, userData.type, newValue(1));
        end

        disp("here")

        updateDesignVariableLines(index,x)
    end
end

%% Function to update the desired solution box in all figures
function updateDesignVariableLines(index, x)
    global h;
    
    for i = 1:length(h.IndividualPlots)
        % Get current axes
        ax = h.IndividualPlots(i);
        
        % Find all line objects in the current axes
        allLines = findobj(ax, 'Type', 'line');
        
        % Initialize empty arrays for vertical and horizontal lines
        vLines = [];
        hLines = [];
        
        % Separate vertical and horizontal lines based on UserData
        for j = 1:length(allLines)
            ud = get(allLines(j), 'UserData');
            if isfield(ud, 'type') && isfield(ud, 'index')
                if ismember(ud.type, {'left', 'right'})
                    vLines = [vLines; allLines(j)];
                elseif ismember(ud.type, {'lower', 'upper'})
                    hLines = [hLines; allLines(j)];
                end
            end
        end
        
        % Update the vertical lines for the given index
        for j = 1:length(vLines)
            ud = get(vLines(j), 'UserData');
            if ud.index == index
                switch ud.type
                    case 'left'
                        % Update the line position based on the new value
                        newValue = x(index).sblb; % Assuming you want to update based on lower bound
                    case 'right'
                        % Update the line position based on the new value
                        newValue = x(index).sbub; % Assuming you want to update based on upper bound
                end
                set(vLines(j), 'XData', [newValue newValue]);
            end
        end
        
        % Update the horizontal lines for the given index
        for j = 1:length(hLines)
            ud = get(hLines(j), 'UserData');
            if ud.index == index
                switch ud.type
                    case 'lower'
                        % Update the line position based on the new value
                        newValue = x(index).sblb; % Assuming you want to update based on lower bound
                    case 'upper'
                        % Update the line position based on the new value
                        newValue = x(index).sbub; % Assuming you want to update based on upper bound
                end
                % Update the line position based on the new value
                set(hLines(j), 'YData', [newValue newValue]);
            end
        end
    end
end




