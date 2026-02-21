function solution_space_box_xray_create_gui(dataManager)
%SOLUTION_SPACE_BOX_XRAY_CREATE_GUI Create GUI for BoxXRay solution space
%   SOLUTION_SPACE_BOX_XRAY_CREATE_GUI creates a comprehensive graphical user
%   interface for exploring and manipulating solution spaces in the BoxXRay
%   framework. The GUI provides interactive controls for design variables,
%   quantities of interest (QOIs), solution space visualization, and
%   optimization capabilities.
%
%   SOLUTION_SPACE_BOX_XRAY_CREATE_GUI(DATAMANAGER) creates a maximized
%   uifigure window with a tabbed interface and solution space visualization
%   panel. The GUI layout consists of a left panel with tabs for configuration
%   and a right panel with interactive 2D projections of the solution space.
%
%   Inputs:
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager object containing design variables, quantities of
%           interest, design parameters, plot configurations, and GUI handles.
%           The object must be initialized with design data (typically via
%           solution_space_box_xray_excel_file_parser) before calling this
%           function.
%
%   Outputs:
%       None (GUI window is created and displayed, handles stored in
%       dataManager)
%
%   GUI Components:
%       The GUI consists of the following main sections:
%
%       1. Tab Group (Left Panel):
%          - Design Variable Tab: Controls for each design variable including
%            sliders, textboxes for design space bounds, solution box bounds,
%            and fixed variable flags
%          - Quantities of Interest Tab: Configuration panels for each QOI
%            with active status checkboxes, lower/upper limit inputs, and
%            violation color pickers
%          - Values from Plot Tab: Dynamic display of selected design variable
%            values from interactive plot interactions
%          - Post-Processing Tab: Save path configuration and file saving
%            controls
%
%       2. Solution Space Visualization Panel (Right Panel):
%          - Grid of axes displaying 2D projections of design variable pairs
%          - Interactive draggable boundary lines for adjusting solution box
%            bounds
%          - Color-coded design samples based on performance criteria and QOI
%            violations
%          - Patch overlays indicating feasible regions
%
%       3. Button Bar (Bottom):
%          - Update Plot Button: Regenerates solution space plots with current
%            bounds and settings
%          - Optimize Button: Runs optimization to find optimal solution box
%            bounds based on current QOI constraints
%
%   GUI Behavior:
%       - The figure is maximized on the monitor specified by
%         dataManager.Monitor
%       - All GUI handles are stored in the dataManager object for callback
%         access
%       - Interactive elements trigger callbacks that update the dataManager
%         and synchronize GUI components
%       - Plot axes support interactive selection of design points for
%         inspection
%
%   Dependencies:
%       Requires BoxXRayGUI package functions:
%       - BoxXRayGUI.create_tab_design_variables
%       - BoxXRayGUI.create_tab_quantities_of_interest
%       - BoxXRayGUI.create_tab_values_from_plot
%       - BoxXRayGUI.create_tab_postprocessing
%       - BoxXRayGUI.create_panel_solution_space_visualization
%
%       Requires BoxXRayCallback package functions for button callbacks
%
%   See also SolutionSpaceBoxXrayDataManager,
%   solution_space_box_xray_excel_file_parser, BoxXRayGUI,
%   BoxXRayCallback.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2024-2025.
%   Copyright 2024-2025 Eduardo Rodrigues Della Noce (Contributor)
%   Copyright 2024-2025 Ali Abbas Kapadia (Main Author)
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

    %% Check correct version of MATLAB
    % check if release year is compatible
    matlabVersion = version;
    positionReleaseIndicator = strfind(matlabVersion,'R');
    matlabVersion = matlabVersion(positionReleaseIndicator:positionReleaseIndicator+5);
    matlabVersionYear = str2double(matlabVersion(2:5));
    matlabVersionRevision = matlabVersion(end);
    if(~(matlabVersionYear >= 2019 || (matlabVersionYear == 2018 && matlabVersionRevision == 'b')))
        error('XRay:IncompatibleMATLABVersion',['Your current MATLAB version is not capable of running this version of the program. \n',...
            'Please use MATLAB R2018b or newer versions of MATLAB.'])
    end
    clear matlabVersion matlabVersionYear matlabVersionRevision;

    % Check if Image Processing Toolbox is installed
    matlabVersionToolboxes = ver;
    isInstalledImageProcessingToolbox = false;
    for i=1:length(matlabVersionToolboxes)
        if strcmp(matlabVersionToolboxes(i).Name,'Image Processing Toolbox')
            isInstalledImageProcessingToolbox = true;
            break;
        end
    end
    if((~isInstalledImageProcessingToolbox))
        error('XRay:MissingToolbox','Image Processing Toolbox is not installed.\nPlease install the required toolbox.');
    end
    clear matlabVersionToolboxes isInstalledImageProcessingToolbox;


    %% Create GUI Main layout
    import matlab.ui.control.Label

    % get monitor to be used
    monitorChosen = dataManager.Monitor;
    monitorPosition = get(0, 'MonitorPositions');
    if(size(monitorPosition,1) < monitorChosen)
        warning('Monitor chosen is out of range, using monitor 1');
        monitorChosen = 1;
    end
    screenSize = monitorPosition(monitorChosen,:);
    clear monitorChosen monitorPosition;

    % Define GUI Screen
    hFig = uifigure('Name', 'Solution Space GUI', 'NumberTitle', 'off');
    hFig.Position = [screenSize(1), screenSize(2)+10, screenSize(3), screenSize(4)-10]; % Set the figure to full screen
    hFig.WindowState = 'maximized';

    % Top-level 1x2 grid in the figure
    mainLayout = uigridlayout(hFig, [2 2]);
    mainLayout.ColumnWidth = {'2x','3x'}; % tabs left, plots right
    mainLayout.RowHeight = {'1x', 50};   % Row 1 = main content, Row 2 = buttons + KPI
    mainLayout.Padding = [10 10 10 10];
    mainLayout.ColumnSpacing = 8;
    mainLayout.RowSpacing = 10;


    %% Column 1 in the layout
    % Define Tabs to be added to the screen
    tabGroup = uitabgroup(mainLayout);
    tabGroup.Layout.Row = 1;
    tabGroup.Layout.Column = 1;

    tabVariables = uitab(tabGroup,"Title","Design Variable");

    % Create tab for constant parameter (Design Paramters)
    if ~((dataManager.isDesignParametersEmpty) && isempty(dataManager.SystemEvaluation))
        tabSystemParameters = uitab(tabGroup,"Title","System Parameters");
    end

    tabQuantities = uitab(tabGroup,"Title","Quantities of Interest");
    tabValues = uitab(tabGroup,"Title","Values from Plot");
    tabPost = uitab(tabGroup,"Title","PostProcessing");
    dataManager.TabGroupHandle = tabGroup;


    %% 1. Tab for Design variables
    BoxXRayGUI.create_tab_design_variables(tabVariables,dataManager);

    %% 2. Tab for Constant Parameters
    if ~((dataManager.isDesignParametersEmpty) && isempty(dataManager.SystemEvaluation))    
        BoxXRayGUI.create_tab_system_parameters(tabSystemParameters,dataManager);
    end

    %% 3. Tab for QoI
    BoxXRayGUI.create_tab_quantities_of_interest(tabQuantities,dataManager);

    %% 4. Tab to display selected values dynamically (for nVars variables)
    BoxXRayGUI.create_tab_values_from_plot(tabValues,dataManager);

    %% 5. Tab to Create Post-processing Panel
    BoxXRayGUI.create_tab_postprocessing(tabPost,dataManager,hFig);

    %% 6. Panel to Create Plot
    BoxXRayGUI.create_panel_solution_space_visualization(mainLayout,dataManager);
    
    %% 7. Button Group
    % Create a nested grid inside the last row of selectionGrid
    buttonGrid = uigridlayout(mainLayout, [1 7]); % 1 row, 7 columns
    buttonGrid.Layout.Row = 2;
    buttonGrid.Layout.Column = [1 2]; % span both columns of parent grid
    buttonGrid.ColumnWidth = {'5x', 90, 90, 90, 90, '0.35x', '3.25x'};
    buttonGrid.Padding = [0 0 0 0];

    % Column 1: Update Plot button at the bottom of the GUI
    btn1 = uibutton(buttonGrid, 'Text', 'Update Plot', ...
        'ButtonPushedFcn', @(src, event) BoxXRayCallback.update_plot(src, event, dataManager));
    btn1.Layout.Row = 1;
    btn1.Layout.Column = [2 3];
    btn1.HorizontalAlignment = 'center';
    btn1.VerticalAlignment = 'center';

    % Column 2: Rerun the Optimization
    btn2 = uibutton(buttonGrid, 'Text', 'Optimize', ...
        'BackgroundColor', [0.94, 0.94, 0.94], ...
        'ButtonPushedFcn', @(src, event) BoxXRayCallback.run_optimization(src, event, dataManager));
    btn2.Layout.Row = 1;
    btn2.Layout.Column = [4 5]; 
    btn2.HorizontalAlignment = 'center';
    btn2.VerticalAlignment = 'center';

    %% 8. KPI Panel
    kpiPanel = uipanel(buttonGrid, ...
        'BackgroundColor',[1 1 1], ...
        'BorderType','line', ...
        'BorderWidth',2, ...
        'HighlightColor','blue');
    
    kpiPanel.Layout.Row = 1;
    kpiPanel.Layout.Column = 7; % span last two columns

    kpiGrid = uigridlayout(kpiPanel, [1 5]);
    kpiGrid.RowHeight = {'fit'};
    kpiGrid.ColumnWidth = {90,25,2,110,50};
    kpiGrid.RowSpacing = 2;

    % Example KPI values
    numFigures = numel(dataManager.PlotAxesHandles);  
    numPointsPerFigure = dataManager.NumberOfSamplesPerPlot; 
    numDesignVariables = size(dataManager.get_design_box, 2);
    
    % Row 1: Number of Figures
    labell1 = uilabel(kpiGrid, 'Text','No. of Figures:','HorizontalAlignment','left','FontWeight','bold');
    labell1.Layout.Row = 1;
    labell1.Layout.Column = 1;
    
    variable1 = uieditfield(kpiGrid, 'text',...
        "Editable",'off', ...
        'Value', num2str(numFigures-1),...
        'HorizontalAlignment','left',...
        'BackgroundColor', [0.94 0.94 0.94]);
    variable1.Layout.Row = 1;
    variable1.Layout.Column = 2;
    
    % Row 2: Points per Figure
    label2 = uilabel(kpiGrid, 'Text','Points per Figure:','HorizontalAlignment','left','FontWeight','bold');
    label2.Layout.Row = 1;
    label2.Layout.Column = 4;
    
    variable2 = uieditfield(kpiGrid, 'numeric',...
        "AllowEmpty",'off', ...
        'Value', numPointsPerFigure,...
        'HorizontalAlignment','left',...
        'BackgroundColor', [0.94 0.94 0.94], ...    
        'ValueChangedFcn', @(src,event) update_points_per_figure(hFig, dataManager, src.Value, event));
    variable2.Layout.Row = 1;
    variable2.Layout.Column = 5;
   
end