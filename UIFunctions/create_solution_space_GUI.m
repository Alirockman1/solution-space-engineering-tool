function create_solution_space_GUI(dataManager)
% CREATE_SOLUTION_SPACE_GUI Generates an interactive GUI for solution space control.
%   CREATE_SOLUTION_SPACE_GUI(DATA_MANAGER) creates a graphical interface 
%   using MATLAB's UI components to explore and configure design variables, 
%   quantities of interest (QoIs), and related parameters within a project.
%
%   INPUT:
%       dataManager - Struct or class instance containing parsed design data
%           from Excel or other sources. Expected fields include:
%               - x: struct of design variables with fields (val, min, max, fixed)
%               - param: struct of fixed design parameters
%               - qoi: struct of quantities of interest or constraints
%
%   FUNCTIONALITY:
%       - Tabs for each design variable with sliders, bounds, and fixed flags
%       - Panels for quantity of interest visualization and parameter inspection
%       - Dynamic update of fields on user interaction
%       - Input validation to ensure consistency
%
%   COMPONENTS:
%       - uifigure: Main GUI window
%       - uitabgroup, uitab: Organizes controls for variables and data
%       - uislider, uieditfield, uicheckbox: Interactive components
%       - uigridlayout, uipanel, uilabel: Layout and display management
%
%   OUTPUT:
%       None (GUI is displayed for user interaction)
%
%   DEPENDENCIES:
%       Assumes dataManager is preloaded with structured data using a
%       compatible Excel parser or similar data ingestion function.
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    %% Create GUI layout

    % Retrive Screen size
    screenSize = get(0, 'ScreenSize');

    % Define GUI Screen
    hFig = uifigure('Name', 'Solution Space GUI', 'NumberTitle', 'off');
    hFig.Position = [screenSize(1), screenSize(2)+10, screenSize(3), screenSize(4)-10]; % Set the figure to full screen
    hFig.WindowState = 'maximized';

    %% Prepare a GUI %%
    % Define Tabs to be added to the screen
    tabGroup = uitabgroup('Parent', hFig, 'Units', 'normalized',...
                        'Position',[.020 .15 0.4 .8]);
    tab1 = uitab(tabGroup,"Title","Design Variable");
    tab4 = uitab(tabGroup,"Title","Quantaties of Interest");
    tab2 = uitab(tabGroup,"Title","Values from Plot");
    tab3 = uitab(tabGroup,"Title","PostProcessing");

    %% 1. Tab for Design variables %%
    % Create a main panel for the sliders and inputs
    mainPanel = uipanel('Parent', tab1, 'Title', 'Design Variables', ...
                        'Units', 'pixels',...
                        'Position', [14.6000   14.4000  516.8000  509.2000],...
                        'Scrollable','on');

    % Sliders and textboxes for each design variable
    nVariables = length(dataManager.DesignVariables);                       % Number of design variables
    dataManager.SliderHandles = gobjects(nVariables, 2);                    % Store slider handles for lower and upper bounds
    dataManager.TextHandles = gobjects(nVariables, 2);                      % Store text box handles for lower and upper values

    % Calculate the initialization of Panel
    initialLeftPos = 11.2800;
    initialBottomPos = 330.0000;
    initialWidthPos = 493.9399;
    initialHeightPos = 143.0099;
    initialGap = 5.5;

    for variableIteration = 1:nVariables
        if variableIteration > 1
            pixelPosition = getpixelposition(variablePanel(variableIteration-1));
            
            left = pixelPosition(1);
            width = pixelPosition(3);
            height = pixelPosition(4);
            bottom = pixelPosition(2)-initialGap-height;
        else
            left   = initialLeftPos;
            width  = initialWidthPos;
            height = initialHeightPos;
            bottom = initialBottomPos;
        end

        % Create a panel for each variable
        variablePanel(variableIteration) = uipanel('Parent', mainPanel, 'Title',...
            dataManager.Labels(variableIteration).dispname, ...
            'Units', 'pixels', ...
            'Position', [left, bottom, width, height]);

        % Design Space Lower Bound
        dataManager.TextHandles.DesignLimits(variableIteration, 1) = uicontrol('Parent', variablePanel(variableIteration),...
            'Style', 'edit', ...
            'String', num2str(dataManager.DesignVariables(variableIteration).dslb, '%.2f'), ...
            'Units', 'pixels', ...
            'Position', [10.0011, 42.0392, 39.0048, 36.0344], ...
            'FontSize', 9, 'ForegroundColor', 'red', ...
            'Callback', @(src, event) design_textbox_callback(src, dataManager, variableIteration, 1));

        % Solution Space Lower Bound
        dataManager.TextHandles.DesignBox(variableIteration, 1) = uicontrol('Parent', variablePanel(variableIteration),...
             'Style', 'edit', ...
             'String', num2str(dataManager.DesignVariables(variableIteration).sblb, '%.2f'), ...
             'Units', 'pixels', ...
             'Position', [54.0065, 42.0392, 39.0048, 36.0344], ...
             'Callback', @(src, event) textbox_callback(dataManager, variableIteration, 1));

        % Create the slider with adjusted position
        dataManager.SliderHandles(variableIteration) = uislider(variablePanel(variableIteration),...
            'range', ...
            'Limits', [dataManager.DesignVariables(variableIteration).dslb dataManager.DesignVariables(variableIteration).dsub], ...
            'Value', [dataManager.DesignVariables(variableIteration).sblb dataManager.DesignVariables(variableIteration).sbub], ...
            'MinorTicks', [], ...
            'Position', [109.0000, 55.000, 273.5000, 3.0000],...
            'ValueChangedFcn', @(src, event) slider_callback(dataManager, variableIteration));

        % Solution Space Upper Bound
        dataManager.TextHandles.DesignBox(variableIteration, 2) = uicontrol('Parent', variablePanel(variableIteration),...
            'Style', 'edit', ...
            'String', num2str(dataManager.DesignVariables(variableIteration).sbub, '%.2f'), ...
            'Units', 'pixels', ...
            'Position', [398.0485, 42.0392, 40.0049, 36.0344], ...
            'Callback', @(src, event) textbox_callback(dataManager, variableIteration, 2));

        % Design Space Upper Bound (rightmost)
        dataManager.TextHandles.DesignLimits(variableIteration, 2) = uicontrol('Parent', variablePanel(variableIteration),...
            'Style', 'edit', ...
            'String', num2str(dataManager.DesignVariables(variableIteration).dsub, '%.2f'), ...
            'Units', 'pixels', ...
            'Position', [443.0540, 42.0392, 39.0048, 36.0344], ...
            'FontSize', 9, 'ForegroundColor', 'red', ...
            'Callback', @(src, event) design_textbox_callback(src, dataManager, variableIteration, 2));
    end

    %% 2. Tab for QoI %%
    QoItab = uipanel('Parent', tab4, 'Title', 'Quantaties of Interest',...
        'Units', 'pixels',...
        'Position', [14.6000   14.4000  516.8000  509.2000],...
        'Scrollable','on');

    % Sliders and textboxes for each design variable
    nQOI = length(dataManager.QOIs);                                       % Number of design variables
    chkHandles = gobjects(nQOI, 1);                                        % Store active status
    dataManager.QOITextHandles = gobjects(nQOI, 2);                        % Store text box handles for lower and upper values

    for variableIteration = 1:nQOI
        if variableIteration > 1
            pixelPosition = getpixelposition(variablePanel(variableIteration-1));
            
            left = pixelPosition(1);
            width = pixelPosition(3);
            height = pixelPosition(4);
            bottom = pixelPosition(2)-initialGap-height;
        else
            left   = initialLeftPos;
            width  = initialWidthPos;
            height = initialHeightPos;
            bottom = initialBottomPos;
        end

        % Create a panel for each variable
        QOIPanel = uipanel('Parent', QoItab, 'Title', dataManager.QOIs(variableIteration).dispname, ...
                           'Units', 'pixels', ...
                           'Position', [left, bottom, width, height]);
    
        % Label for 'InActive'
        uicontrol('Parent', QOIPanel, 'Style', 'text', 'String', 'InActive', ...
                  'Units', 'pixels', 'Position', [5.9200, 65.5000, 73.8000, 35.400], ...
                  'HorizontalAlignment', 'center');
    
        % Checkbox for 'InActive'
        chkHandles(variableIteration) = uicontrol('Parent', QOIPanel, ...
                        'Style', 'checkbox', ...
                        'Units', 'pixels', ...
                        'Position', [34.0000, 55.0000, 20.0000, 20.0000], ...
                        'FontSize', 10, ...
                        'Callback', @(hObject, ~) toggle_textbox(hObject, dataManager, variableIteration));
    
        % Label for 'Lower Bound'
        uicontrol('Parent', QOIPanel, 'Style', 'text', 'String', 'Lower Bound', ...
                  'Units', 'pixels', 'Position', [115.7000, 65.5000, 73.8000, 35.4000], ...
                  'HorizontalAlignment', 'center');
    
        % Label for 'Upper Bound'
        uicontrol('Parent', QOIPanel, 'Style', 'text', 'String', 'Upper Bound', ...
                  'Units', 'pixels', 'Position', [235.0000, 65.5000, 73.8000, 35.4000], ...
                  'HorizontalAlignment', 'center');
    
        % Textbox for the lower bound
        dataManager.QOITextHandles(variableIteration, 1) = uicontrol('Parent', QOIPanel, 'Style', 'edit', ...
            'String', num2str(dataManager.QOIs(variableIteration).crll, '%.2f'), ...
            'Units', 'pixels', ...
            'Position', [99.4000, 45.0000, 98.5000, 30.000]);              % Centered below 'Lower Bound'
    
        % Textbox for the upper bound
        dataManager.QOITextHandles(variableIteration, 2) = uicontrol('Parent', QOIPanel, 'Style', 'edit', ...
            'String', num2str(dataManager.QOIs(variableIteration).crul, '%.2f'), ...
            'Units', 'pixels', ...
            'Position', [230.0000, 45.0000, 98.5000, 30.000]);             % Centered below 'Upper Bound'
        
        % Label for 'Colour'
        uicontrol('Parent', QOIPanel, 'Style', 'text', 'String', 'Colour', ...
                  'Units', 'pixels', 'Position', [363.5000, 65.5000, 73.8000, 35.4000], ...
                  'HorizontalAlignment', 'center');
        
        % Add the uicolorpicker with adjusted position
        uicolorpicker('Parent', QOIPanel, ...
                    'Position', [378.5000, 47.5000, 40.000, 30.000], ...
                    ValueChangedFcn=@(src,event) update_color(src, dataManager, variableIteration));
    end

    %% 3. Update QOI
    uicontrol('Parent', QoItab, 'Style', 'pushbutton', 'String', 'Update QOI Data', ...
              'Units', 'normalized', 'Position', [0.375, 0.035, 0.25, 0.08], ...
              'BackgroundColor', [0.94, 0.94, 0.94], ...
              'Callback', @(src, event) update_qoi_callback(dataManager, nQOI));


    %% 4. Tab to display selected values dynamically (for nVars variables) %%
    selectionPanel = uipanel('Parent', tab2, 'Title', 'Selected Values from Plot', ...
                             'Units', 'normalized',...
                             'Position', [0.015 0.15 0.9 0.875]);

    % Create a dynamic display for each variable
    dataManager.DataTextHandles = gobjects(nVariables + ...
        length(dataManager.QOIs.varname), 1);                              % Store text area handles

    for tA = 1:nVariables
        % Labels for each design variable
        uicontrol('Parent', selectionPanel, 'Style', 'text',...
            'String', [dataManager.Labels(tA).dispname ':'], ...
            'Units', 'normalized', 'Position', [0.05, 1 - tA*0.15, 0.3, 0.1]);

        % Text areas for each variable to display selected value
        dataManager.DataTextHandles(tA) = uicontrol('Parent', selectionPanel, ...
            'Style', 'edit', 'String', 'N/A','Units', 'normalized', ...
            'Position', [0.35, 1 - tA*0.15, 0.6, 0.1], 'Enable', 'off');
    end

    % Labels for design variable
    for JA = 1:length(dataManager.QOIs.varname)
        uicontrol('Parent', selectionPanel, 'Style', 'text',...
            'String', dataManager.QOIs.varname(JA), ...
            'Units', 'normalized', 'Position', [0.05, 1 - (tA+JA)*0.15, 0.3, 0.1]);
    
        % Text areas for design variable
        dataManager.DataTextHandles(tA+JA) = uicontrol('Parent', selectionPanel, ...
            'Style', 'edit', 'String', 'N/A','Units', 'normalized', ...
            'Position', [0.35, 1 - (tA+JA)*0.15, 0.6, 0.1],'Enable', 'off');
    end

    % 2. Add a Button to Select Data from the Plot
    uicontrol('Parent', selectionPanel, 'Style', 'pushbutton',...
        'String', 'Select Point from Plot', 'Units', 'normalized', ...
        'Position', [0.15, 1 - (tA+2.5)*0.15, 0.6, 0.1], ...
        'Callback', @(btn, event) activate_selection_mode(dataManager));

    %% 5. Tab to Create Post-processing Panel %%

    % Create the Post-processing Panel with relative position in the main figure
    postProcessingPanel = uipanel('Parent', tab3, 'Title', 'Post-processing', ...
                                  'Units', 'normalized',...
                                  'Position', [0.015, 0.55, 0.95, 0.4]);
    
    % Text box for Excel file name
    uicontrol('Parent', postProcessingPanel, 'Style', 'text', 'String', 'Excel File Name:', ...
        'Units', 'normalized', 'Position', [0.05, 0.8, 0.5, 0.1], 'HorizontalAlignment', 'left');
    dataManager.PostTextHandles(1) = uicontrol('Parent', postProcessingPanel, 'Style', 'edit', ...
        'Units', 'normalized', 'Position', [0.35, 0.8, 0.45, 0.1]);
    
    % Text box for Figure file name
    uicontrol('Parent', postProcessingPanel, 'Style', 'text', 'String', 'Figure File Name:', ...
        'Units', 'normalized', 'Position', [0.05, 0.6, 0.5, 0.1], 'HorizontalAlignment', 'left');
    dataManager.PostTextHandles(2) = uicontrol('Parent', postProcessingPanel, 'Style', 'edit', ...
        'Units', 'normalized', 'Position', [0.35, 0.6, 0.45, 0.1]);
    
    % Text box for Save Path
    uicontrol('Parent', postProcessingPanel, 'Style', 'text', 'String', 'Save Path:', ...
        'Units', 'normalized', 'Position', [0.05, 0.4, 0.5, 0.1], 'HorizontalAlignment', 'left');
    dataManager.PostTextHandles(3) = uicontrol('Parent', postProcessingPanel, 'Style', 'edit', ...
        'Units', 'normalized', 'Position', [0.35, 0.4, 0.55, 0.1]);
    
    % Save button at the bottom of the GUI
    uicontrol('Parent', postProcessingPanel, 'Style', 'pushbutton',...
        'String', 'Save Figure and Data','Units', 'normalized',...
        'Position', [0.2, 0.1, 0.6, 0.15],...
        'Callback', @(src, event) save_files(src, event, dataManager, hFig));
    
    %% 6. Update Plot button at the bottom of the GUI
    uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Update Plot', ...
              'Units', 'normalized', 'Position', [0.325, 0.035, 0.2, 0.08], ...
              'Callback', @(src, event) update_plot(dataManager,nVariables));
    
    %% 7. Rerun the Optimization
    uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Optimize', ...
              'Units', 'normalized', 'Position', [0.55, 0.035, 0.1, 0.08], ...
              'BackgroundColor', [0.94, 0.94, 0.94], ...
              'Callback', @(src, event) run_optimization(dataManager));

    %% 8. Plot
    % Create the figure box for placing figure
    axisPanel = uipanel('Parent', hFig, 'Title', 'Solution Space', ...
                        'Units', 'pixels', ...
                        'BackgroundColor', [1 1 1], ...
                        'Position', [615.7000, 113.3500, 683.0000, 599.2000],...
                        'Scrollable','on');

    % Create the Ui Axes for the solution Space
    % Fixed dimensions and spacing
    axWidth  = 153;
    axHeight = 455;
    gap = 55;
    
    % Base offsets (lower-left of first plot)
    initialX = 55;
    initialY = 60;
    
    % Number of plots and layout
    numberPlots = numel(dataManager.DesiredPlots);
    numberColumns = min(3, numberPlots);                                   % Max 3 columns
    numberRows = ceil(numberPlots / numberColumns);                        % Compute rows
    
    % Preallocate axes handles
    dataManager.AxisHandles.IndividualPlots = gobjects(1, numberPlots);
    
    for i = 1:numberPlots
        row = numberRows - floor((i-1) / numberColumns);                   % Top-to-bottom row index
        col = mod(i-1, numberColumns) + 1;                                 % Left-to-right column index
    
        % Compute pixel position for each axis
        posX = initialX + (col - 1) * (axWidth + gap);
        posY = initialY + (row - 1) * (axHeight + gap);
    
        % Create axes
        dataManager.AxisHandles.IndividualPlots(i) = axes('Parent', axisPanel, ...
            'Units', 'pixels', ...
            'Position', [posX, posY, axWidth, axHeight], ...
            'Tag', sprintf('Plot%d', i), ...
            'XLimMode', 'manual', ...
            'YLimMode', 'manual', ...
            'NextPlot', 'replacechildren');
    
        % Disable default tools but keep object interactivity
        axis(dataManager.AxisHandles.IndividualPlots(i), 'manual');
        zoom(dataManager.AxisHandles.IndividualPlots(i), 'off');
        pan(dataManager.AxisHandles.IndividualPlots(i), 'off');
        rotate3d(dataManager.AxisHandles.IndividualPlots(i), 'off');
        set(dataManager.AxisHandles.IndividualPlots(i), ...
            'HitTest', 'on', 'PickableParts', 'all');
    end

    solution_space_plot_axis(dataManager);

end