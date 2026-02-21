classdef SolutionSpaceBoxXrayDataManager < handle
%SOLUTIONSPACEBOXXRAYDATAMANAGER Data manager for BoxXRay solution space GUI
%   SOLUTIONSPACEBOXXRAYDATAMANAGER is a handle class that manages all data
%   structures, GUI handles, and configuration settings for the BoxXRay
%   solution space exploration tool. It serves as the central data repository
%   and provides methods for initializing, updating, and querying design
%   variables, quantities of interest (QOIs), design parameters, and plot
%   configurations.
%
%   The class maintains both the core problem data (design variables, QOIs,
%   parameters) and GUI-related handles (textboxes, sliders, axes, draggable
%   lines) to enable bidirectional synchronization between the GUI interface
%   and the underlying data model.
%
%   SOLUTIONSPACEBOXXRAYDATAMANAGER Properties:
%       Public Properties:
%       - SystemEvaluation : function_handle, BottomUpMappingBase, or
%         DesignEvaluatorBase
%           Function or object used to evaluate system performance and physical
%           feasibility for given design samples
%       - Monitor : double (default: 1)
%           Monitor number on which to display the GUI window
%       - OptimizationOptions : cell array
%           Options passed to optimization algorithms
%       - MaximumNumberOfPlotsPerRow : double (default: 3)
%           Maximum number of plot axes to display per row in the visualization
%           panel
%       - SamplingMethod : function_handle or []
%           Method used for sampling design space for visualization
%       - SamplingOptions : cell array
%           Options passed to the sampling method
%       - NumberOfSamplesPerPlot : double or []
%           Number of sample points to generate for each plot
%       - MarkerColorsCriterion : double array or []
%           Criterion values used for color-coding plot markers
%       - PlotOptionsGood, PlotOptionsBad, PlotOptionsPhysicallyInfeasible,
%         PlotOptionsIntervals, PlotOptionsBox : cell arrays
%           Plotting options for different marker types and plot elements
%       - DraggableLinesColor : char or double array (default: 'b')
%           Color for draggable boundary lines in plots
%       - DraggableLineOptions : cell array
%           Additional options for draggable line appearance
%       - PatchRelativeWidth : double (default: 0.05)
%           Relative width of patch overlays on draggable lines
%       - PatchAlpha : double (default: 0.01)
%           Transparency alpha value for patch overlays
%       - PatchOptions : cell array
%           Additional options for patch appearance
%       - PlotData : double array or []
%           Cached plot data for visualization
%       - EvaluationData : struct or []
%           Cached evaluation results from system function
%       - SaveFolder : char or []
%           Default folder path for saving plots and data
%       - TextboxDesignSpaceHandles, TextboxDesignBoxHandles : gobjects arrays
%           Handles to textboxes displaying design space and solution box bounds
%       - SliderHandles : gobjects array
%           Handles to sliders for adjusting solution box bounds
%       - TextboxSelectDataHandles : gobjects array
%           Handles to textboxes displaying selected design variable values
%       - TextboxSavePathHandle : gobjects
%           Handle to textbox for save path input
%       - PlotAxesHandles : gobjects array
%           Handles to axes objects for solution space plots
%       - TabGroupHandle : uitabgroup or []
%           Handle to the main tab group in the GUI
%       - DraggabbleVerticalLineHandles, DraggabbleHorizontalLineHandles :
%         cell arrays
%           Handles to draggable lines for adjusting bounds in plots
%       - DraggabbleVerticalPatchHandles, DraggabbleHorizontalPatchHandles :
%         cell arrays
%           Handles to patch overlays on draggable lines
%
%       Protected Properties:
%       - DesignVariables : struct array
%           Array of design variable structures, each containing VariableName,
%           DisplayName, Description, Unit, DesignSpaceLowerBound,
%           DesignSpaceUpperBound, BoxLowerBound, BoxUpperBound
%       - QuantatiesOfInterests : struct array
%           Array of QOI structures, each containing VariableName, DisplayName,
%           Description, Unit, LowerLimit, UpperLimit, ColorWhenViolated,
%           ViolatedText, ActiveStatus
%       - DesignParameters : struct array
%           Array of constant parameter structures, each containing
%           VariableName, DisplayName, Description, Unit, Value
%       - PlotDesiredPairs : double array (nPairs x 2)
%           Array of design variable index pairs for 2D projection plots
%
%   SOLUTIONSPACEBOXXRAYDATAMANAGER Methods:
%       Constructor:
%       - SolutionSpaceBoxXrayDataManager : Create data manager object
%
%       Initialization Methods:
%       - set_design_variables : Initialize and validate design variables
%       - set_quantities_of_interest : Initialize and validate QOIs
%       - set_system_parameters : Initialize and validate design
%         parameters
%       - set_plot_desired_pairs : Initialize plot pair configurations
%
%       Update Methods:
%       - update_design_box_lower_bounds : Update solution box lower bounds
%       - update_design_box_upper_bounds : Update solution box upper bounds
%       - update_design_space_lower_bounds : Update design space lower bounds
%       - update_design_space_upper_bounds : Update design space upper bounds
%       - update_quantities_of_interest_lower_limits : Update QOI lower limits
%       - update_quantities_of_interest_upper_limits : Update QOI upper limits
%       - update_quantities_of_interest_active_status : Toggle QOI active
%         status
%       - update_quantities_of_interest_color_when_violated : Update QOI
%         violation colors
%
%       Getter Methods:
%       - get_design_variable_names : Get array of design variable names
%       - get_design_variable_display_names : Get array of display names
%       - get_design_box : Get solution box bounds matrix
%       - get_design_space : Get design space bounds matrix
%       - get_quantities_of_interest_names : Get array of QOI names
%       - get_quantities_of_interest_display_names : Get array of QOI display
%         names
%       - get_quantities_of_interest_limits : Get QOI limits matrix
%       - get_quantities_of_interest_colors_when_violated : Get QOI violation
%         colors
%       - get_design_parameters : Get design parameter values array
%       - get_plot_desired_pairs : Get plot pair configuration array
%       - get_quantities_of_interest_violated_text : Get QOI violation text
%         cell array
%       - get_quantities_of_interest_active_status : Get QOI active status
%         logical array
%
%       Utility Methods:
%       - set : Set multiple properties using name-value pairs
%
%   See also solution_space_box_xray_excel_file_parser,
%   solution_space_box_xray_create_gui, BottomUpMappingBase,
%   DesignEvaluatorBase.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2024-2025.
%   Copyright 2024-2025 Eduardo Rodrigues Della Noce (Author)
%   Copyright 2024-2025 Ali Abbas Kapadia (Author)
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

    properties(Access = public)
        %SYSTEMEVALUATION Function or object for system evaluation
        %	SYSTEMEVALUATION is the function handle, BottomUpMappingBase object,
        %	or DesignEvaluatorBase object used to evaluate system performance
        %	and physical feasibility for given design samples. This function or
        %	object is called during solution space visualization and optimization
        %	to compute performance measures and physical feasibility measures
        %	for design points.
        %
        %	SYSTEMEVALUATION can be:
        %		- function_handle : MATLAB function that accepts design samples
        %		and returns performance measures (and optionally physical
        %		feasibility measures)
        %		- BottomUpMappingBase : Object derived from BottomUpMappingBase
        %		that provides a response method for system evaluation
        %		- DesignEvaluatorBase : Object derived from DesignEvaluatorBase
        %		that provides evaluation capabilities
        %
        %	SYSTEMEVALUATION : function_handle OR BottomUpMappingBase OR
        %	DesignEvaluatorBase
        %
        %	See also BottomUpMappingBase, DesignEvaluatorBase, response.
        SystemEvaluation

        %MONITOR Monitor number for GUI display
        %	MONITOR specifies which monitor to use for displaying the GUI
        %	window. The GUI figure will be maximized on the specified monitor.
        %	If the monitor number exceeds the available monitors, monitor 1 is
        %	used with a warning.
        %
        %	MONITOR : (1,1) double
        %	Default: 1
        %
        %	See also solution_space_box_xray_create_gui.
        Monitor = 1;

        %OPTIMIZATIONOPTIONS Options passed to optimization algorithms
        %	OPTIMIZATIONOPTIONS is a cell array of name-value pairs that are
        %	passed to the optimization algorithm (e.g., sso_box_stochastic) when
        %	running optimization. These options control optimization behavior
        %	such as convergence criteria, maximum iterations, and algorithm
        %	specific settings.
        %
        %	OPTIMIZATIONOPTIONS : cell array
        %	Default: {}
        %
        %	See also run_optimization, sso_box_stochastic.
        OptimizationOptions = {};

        %MAXIMUMNUMBEROFPLOTSPERROW Maximum number of plot axes per row
        %	MAXIMUMNUMBEROFPLOTSPERROW specifies the maximum number of plot axes
        %	to display per row in the solution space visualization panel. The
        %	actual number of columns may be less if there are fewer plots than
        %	this maximum.
        %
        %	MAXIMUMNUMBEROFPLOTSPERROW : (1,1) double
        %	Default: 3
        %
        %	See also create_panel_solution_space_visualization.
        MaximumNumberOfPlotsPerRow = 3;

        %SAMPLINGMETHOD Method for sampling design space
        %	SAMPLINGMETHOD is a function handle to the method used for sampling
        %	the design space when generating visualization plots. If empty, a
        %	default sampling method is used. The sampling method is called
        %	during solution space evaluation to generate design sample points
        %	for plotting.
        %
        %	SAMPLINGMETHOD : function_handle OR []
        %	Default: []
        %
        %	See also SamplingOptions, NumberOfSamplesPerPlot,
        %	evaluate_selective_design_space_projection.
        SamplingMethod = [];

        %SAMPLINGOPTIONS Options passed to sampling method
        %	SAMPLINGOPTIONS is a cell array of name-value pairs that are passed
        %	to the sampling method function when generating design samples for
        %	visualization. These options control sampling behavior such as
        %	random seed, distribution type, or method-specific parameters.
        %
        %	SAMPLINGOPTIONS : cell array
        %	Default: {}
        %
        %	See also SamplingMethod, evaluate_selective_design_space_projection.
        SamplingOptions = {};

        %NUMBEROFSAMPLESPERPLOT Number of sample points per plot
        %	NUMBEROFSAMPLESPERPLOT specifies the number of design sample points
        %	to generate for each 2D projection plot. If empty, a default number
        %	is used based on the problem dimensions and available computational
        %	resources.
        %
        %	NUMBEROFSAMPLESPERPLOT : (1,1) double OR []
        %	Default: []
        %
        %	See also SamplingMethod, SamplingOptions,
        %	evaluate_selective_design_space_projection.
        NumberOfSamplesPerPlot = [];

        %MARKERCOLORSCRITERION Criterion values for marker color-coding
        %	MARKERCOLORSCRITERION is an array of criterion values used for
        %	color-coding plot markers based on performance measures. If provided,
        %	markers are colored according to these criterion values, enabling
        %	visual identification of design points with specific performance
        %	characteristics.
        %
        %	MARKERCOLORSCRITERION : double array OR []
        %	Default: []
        %
        %	See also evaluate_selective_design_space_projection,
        %	plot_design_space_projection_axis.
        MarkerColorsCriterion = [];

        %PLOTOPTIONSGOOD Plotting options for good design points
        %	PLOTOPTIONSGOOD is a cell array of name-value pairs specifying
        %	plotting options for design points that satisfy all QOI constraints
        %	and are physically feasible. These options are passed to the plot
        %	function when rendering markers for good designs (e.g., 'Marker',
        %	'MarkerSize', 'Color').
        %
        %	PLOTOPTIONSGOOD : cell array
        %	Default: {}
        %
        %	See also PlotOptionsBad, PlotOptionsPhysicallyInfeasible,
        %	plot_design_space_projection_axis.
        PlotOptionsGood = {};

        %PLOTOPTIONSBAD Plotting options for bad design points
        %	PLOTOPTIONSBAD is a cell array of name-value pairs specifying
        %	plotting options for design points that violate one or more QOI
        %	constraints but are physically feasible. These options control the
        %	appearance of markers for bad designs.
        %
        %	PLOTOPTIONSBAD : cell array
        %	Default: {}
        %
        %	See also PlotOptionsGood, PlotOptionsPhysicallyInfeasible,
        %	plot_design_space_projection_axis.
        PlotOptionsBad = {};

        %PLOTOPTIONSPHYSICALLYINFEASIBLE Plotting options for infeasible points
        %	PLOTOPTIONSPHYSICALLYINFEASIBLE is a cell array of name-value pairs
        %	specifying plotting options for design points that are physically
        %	infeasible (violate physical constraints). These options control
        %	the appearance of markers for infeasible designs.
        %
        %	PLOTOPTIONSPHYSICALLYINFEASIBLE : cell array
        %	Default: {}
        %
        %	See also PlotOptionsGood, PlotOptionsBad,
        %	plot_design_space_projection_axis.
        PlotOptionsPhysicallyInfeasible = {};

        %PLOTOPTIONSINTERVALS Plotting options for QOI limit intervals
        %	PLOTOPTIONSINTERVALS is a cell array of name-value pairs specifying
        %	plotting options for displaying QOI limit intervals on plots. These
        %	options control the appearance of interval markers or lines
        %	indicating QOI constraint boundaries.
        %
        %	PLOTOPTIONSINTERVALS : cell array
        %	Default: {}
        %
        %	See also plot_design_space_projection_axis.
        PlotOptionsIntervals = {};

        %PLOTOPTIONSBOX Plotting options for solution box boundaries
        %	PLOTOPTIONSBOX is a cell array of name-value pairs specifying
        %	plotting options for displaying the solution box boundaries on
        %	plots. These options control the appearance of rectangle outlines or
        %	other visualizations of the solution box bounds.
        %
        %	PLOTOPTIONSBOX : cell array
        %	Default: {}
        %
        %	See also plot_design_space_projection_axis.
        PlotOptionsBox = {};

        %AXISLABELSOPTIONS Options for axis labels
        %	AXISLABELSOPTIONS is a cell array of name-value pairs specifying
        %	options for the axis labels. These options control the appearance
        %	of the axis labels.
        %
        %	AXISLABELSOPTIONS : cell array
        %	Default: {}
        %
        %	See also plot_design_space_projection_axis.
        AxisLabelsOptions = {};

        %LEGENDOPTIONS Options for legend
        %	LEGENDOPTIONS is a cell array of name-value pairs specifying
        %	options for the legend. These options control the appearance
        %	of the legend.
        %
        %	LEGENDOPTIONS : cell array
        %	Default: {}
        %
        %	See also solution_space_plot_axis_patch.
        LegendOptions = {};

        %DRAGGABLELINESCOLOR Color for draggable boundary lines
        %	DRAGGABLELINESCOLOR specifies the color used for draggable boundary
        %	lines in plots. These lines allow interactive adjustment of solution
        %	box bounds by dragging. The color can be specified as a character
        %	(e.g., 'b', 'r', 'g') or as an RGB triple [r, g, b].
        %
        %	DRAGGABLELINESCOLOR : char OR (1,3) double
        %	Default: 'b'
        %
        %	See also DraggableLineOptions, solution_space_plot_axis_patch.
        DraggableLinesColor = 'b';

        %DRAGGABLELINEOPTIONS Additional options for draggable lines
        %	DRAGGABLELINEOPTIONS is a cell array of name-value pairs specifying
        %	additional appearance options for draggable boundary lines (e.g.,
        %	'LineWidth', 'LineStyle'). These options are applied when creating
        %	the draggable lines in plots.
        %
        %	DRAGGABLELINEOPTIONS : cell array
        %	Default: {}
        %
        %	See also DraggableLinesColor, solution_space_plot_axis_patch.
        DraggableLineOptions = {};

        %PATCHRELATIVEWIDTH Relative width of patch overlays
        %	PATCHRELATIVEWIDTH specifies the relative width of patch overlays on
        %	draggable lines, expressed as a fraction of the axis range. These
        %	patches provide a larger interactive area for dragging boundary
        %	lines, making it easier to select and move them.
        %
        %	PATCHRELATIVEWIDTH : (1,1) double
        %	Default: 0.01
        %
        %	See also PatchAlpha, PatchOptions, create_patch_for_line.
        PatchRelativeWidth = 0.01;

        %PATCHALPHA Transparency alpha value for patch overlays
        %	PATCHALPHA specifies the transparency (alpha) value for patch
        %	overlays on draggable lines. A value of 0.01 makes patches nearly
        %	transparent while still being interactive, allowing the underlying
        %	plot content to be visible.
        %
        %	PATCHALPHA : (1,1) double
        %	Default: 0.01
        %
        %	See also PatchRelativeWidth, PatchOptions, create_patch_for_line.
        PatchAlpha = 0.01;

        %PATCHOPTIONS Additional options for patch overlays
        %	PATCHOPTIONS is a cell array of name-value pairs specifying
        %	additional appearance options for patch overlays on draggable lines
        %	(e.g., 'FaceColor', 'EdgeColor'). These options control the visual
        %	appearance of the interactive patches.
        %
        %	PATCHOPTIONS : cell array
        %	Default: {}
        %
        %	See also PatchRelativeWidth, PatchAlpha, create_patch_for_line.
        PatchOptions = {};

        %PLOTDATA Cached plot data for visualization
        %	PLOTDATA stores the cached plot data structure returned from
        %	evaluate_selective_design_space_projection. This data contains
        %	design samples, performance measures, and feasibility information for
        %	each plot pair, enabling efficient replotting without re-evaluation.
        %
        %	PLOTDATA : struct array OR []
        %	Default: []
        %
        %	See also EvaluationData, evaluate_selective_design_space_projection,
        %	solution_space_plot_axis_patch.
        PlotData = [];

        %EVALUATIONDATA Cached evaluation results from system function
        %	EVALUATIONDATA stores the cached evaluation results structure
        %	returned from evaluate_selective_design_space_projection. This data
        %	contains detailed evaluation information including system outputs and
        %	intermediate computation results.
        %
        %	EVALUATIONDATA : struct OR []
        %	Default: []
        %
        %	See also PlotData, evaluate_selective_design_space_projection,
        %	solution_space_plot_axis_patch.
        EvaluationData = [];

        %OPTIMIZATIONDATA Optimization data from optimization algorithm
        %	OPTIMIZATIONDATA stores the optimization data returned from the
        %   stochastic box-shaped solution space optimization algorithm.
        %
        %	OPTIMIZATIONDATA : struct OR []
        %	Default: []
        %
        %	See also run_optimization, sso_box_stochastic.
        OptimizationData = [];

        %SAVEFOLDER Default folder path for saving plots and data
        %	SAVEFOLDER specifies the default folder path used when saving plots
        %	and data files through the GUI. If empty, the current working
        %	directory is used or the user is prompted to select a folder.
        %
        %	SAVEFOLDER : char OR []
        %	Default: []
        %
        %	See also save_files, TextboxSavePathHandle.
        SaveFolder = [];

        %TEXTBOXDESIGNSPACEHANDLES Handles to design space bound textboxes
        %	TEXTBOXDESIGNSPACEHANDLES is a gobjects array of size (2, nVars)
        %	containing handles to textboxes that display design space bounds.
        %	Row 1 contains handles for lower bound textboxes, row 2 contains
        %	handles for upper bound textboxes. Each column corresponds to a
        %	design variable.
        %
        %	TEXTBOXDESIGNSPACEHANDLES : (2, nVars) gobjects
        %	Default: gobjects(2, 0)
        %
        %	See also TextboxDesignBoxHandles, create_tab_design_variables.
        TextboxDesignSpaceHandles = gobjects(2, 0);

        %TEXTBOXDESIGNBOXHANDLES Handles to solution box bound textboxes
        %	TEXTBOXDESIGNBOXHANDLES is a gobjects array of size (2, nVars)
        %	containing handles to textboxes that display solution box bounds.
        %	Row 1 contains handles for lower bound textboxes, row 2 contains
        %	handles for upper bound textboxes. Each column corresponds to a
        %	design variable.
        %
        %	TEXTBOXDESIGNBOXHANDLES : (2, nVars) gobjects
        %	Default: gobjects(2, 0)
        %
        %	See also TextboxDesignSpaceHandles, create_tab_design_variables.
        TextboxDesignBoxHandles = gobjects(2, 0);

        %SLIDERHANDLES Handles to sliders for adjusting solution box bounds
        %	SLIDERHANDLES is a gobjects array of size (1, nVars) containing
        %	handles to sliders that allow interactive adjustment of solution box
        %	bounds. Each slider controls both lower and upper bounds for a
        %	design variable.
        %
        %	SLIDERHANDLES : (1, nVars) gobjects
        %	Default: gobjects(1, 0)
        %
        %	See also create_tab_design_variables,
        %	update_box_bounds_given_slider_input.
        SliderHandles = gobjects(1, 0);

        %TEXTBOXSELECTDATAHANDLES Handles to selected design value textboxes
        %	TEXTBOXSELECTDATAHANDLES is a gobjects array of size (1, nVars)
        %	containing handles to textboxes that display selected design
        %	variable values from interactive plot interactions. These textboxes
        %	are updated when the user clicks on design points in plots.
        %
        %	TEXTBOXSELECTDATAHANDLES : (1, nVars) gobjects
        %	Default: gobjects(1, 0)
        %
        %	See also create_tab_values_from_plot, select_data_from_plot.
        TextboxSelectDataHandles = gobjects(1, 0);

        %TEXTBOXSAVEPATHHANDLE Handle to save path input textbox
        %	TEXTBOXSAVEPATHHANDLE is a gobjects handle to the textbox used for
        %	inputting the save path for plots and data files. Users can type
        %	or browse for a folder path in this textbox.
        %
        %	TEXTBOXSAVEPATHHANDLE : gobjects
        %	Default: gobjects(1,1)
        %
        %	See also SaveFolder, create_tab_postprocessing, save_files.
        TextboxSavePathHandle = gobjects(1,1);

        %PLOTAXESHANDLES Handles to axes objects for solution space plots
        %	PLOTAXESHANDLES is a gobjects array containing handles to uiaxes
        %	objects used for displaying 2D projections of the solution space.
        %	Each handle corresponds to one plot pair specified in
        %	PlotDesiredPairs.
        %
        %	PLOTAXESHANDLES : (1, nPlots) gobjects
        %
        %	See also PlotDesiredPairs, create_panel_solution_space_visualization,
        %	solution_space_plot_axis_patch.
        PlotAxesHandles

        %TABGROUPHANDLE Handle to main tab group in GUI
        %	TABGROUPHANDLE is a uitabgroup handle containing all tabs in the
        %	GUI (Design Variables, Quantities of Interest, Values from Plot,
        %	Post-Processing). This handle is used to access and manipulate the
        %	tabbed interface.
        %
        %	TABGROUPHANDLE : uitabgroup OR []
        %	Default: []
        %
        %	See also solution_space_box_xray_create_gui.
        TabGroupHandle = [];

        %DRAGGABBLEVERTICALLINEHANDLES Handles to vertical draggable lines
        %	DRAGGABBLEVERTICALLINEHANDLES is a cell array of size (1, nVars)
        %	where each cell contains handles to vertical draggable lines
        %	representing lower or upper bounds for a design variable. These
        %	lines appear in plots where the variable is on the x-axis.
        %
        %	DRAGGABBLEVERTICALLINEHANDLES : cell array (1, nVars)
        %	Default: {}
        %
        %	See also DraggabbleHorizontalLineHandles,
        %	DraggabbleVerticalPatchHandles, solution_space_plot_axis_patch.
        DraggabbleVerticalLineHandles = {};

        %DRAGGABBLEVERTICALPATCHHANDLES Handles to vertical draggable patches
        %	DRAGGABBLEVERTICALPATCHHANDLES is a cell array of size (1, nVars)
        %	where each cell contains handles to patch overlays on vertical
        %	draggable lines. These patches provide a larger interactive area for
        %	dragging boundary lines.
        %
        %	DRAGGABBLEVERTICALPATCHHANDLES : cell array (1, nVars)
        %	Default: {}
        %
        %	See also DraggabbleVerticalLineHandles, PatchRelativeWidth,
        %	create_patch_for_line.
        DraggabbleVerticalPatchHandles = {};

        %DRAGGABBLEHORIZONTALLINEHANDLES Handles to horizontal draggable lines
        %	DRAGGABBLEHORIZONTALLINEHANDLES is a cell array of size (1, nVars)
        %	where each cell contains handles to horizontal draggable lines
        %	representing lower or upper bounds for a design variable. These
        %	lines appear in plots where the variable is on the y-axis.
        %
        %	DRAGGABBLEHORIZONTALLINEHANDLES : cell array (1, nVars)
        %	Default: {}
        %
        %	See also DraggabbleVerticalLineHandles,
        %	DraggabbleHorizontalPatchHandles, solution_space_plot_axis_patch.
        DraggabbleHorizontalLineHandles = {};

        %DRAGGABBLEHORIZONTALPATCHHANDLES Handles to horizontal draggable patches
        %	DRAGGABBLEHORIZONTALPATCHHANDLES is a cell array of size (1, nVars)
        %	where each cell contains handles to patch overlays on horizontal
        %	draggable lines. These patches provide a larger interactive area for
        %	dragging boundary lines.
        %
        %	DRAGGABBLEHORIZONTALPATCHHANDLES : cell array (1, nVars)
        %	Default: {}
        %
        %	See also DraggabbleHorizontalLineHandles, PatchRelativeWidth,
        %	create_patch_for_line.
        DraggabbleHorizontalPatchHandles = {};

    end
    
    properties(Access = protected)
        %DESIGNVARIABLES Struct array of design variable definitions
        %	DESIGNVARIABLES is a struct array where each element represents one
        %	design variable. Each struct must contain the following fields:
        %		- VariableName : char - unique identifier for the variable
        %		- DisplayName : char - name displayed in GUI
        %		- Description : char - description of the variable
        %		- Unit : char - unit of measurement
        %		- DesignSpaceLowerBound : double - lower bound of design space
        %		- DesignSpaceUpperBound : double - upper bound of design space
        %		- BoxLowerBound : double - lower bound of solution box
        %		- BoxUpperBound : double - upper bound of solution box
        %
        %	DESIGNVARIABLES : struct array
        %
        %	See also set_design_variables, get_design_variable_names,
        %	get_design_box.
        DesignVariables

        %QUANTATIESOFINTERESTS Struct array of quantity of interest definitions
        %	QUANTATIESOFINTERESTS is a struct array where each element represents
        %	one quantity of interest (QOI). Each struct must contain the
        %	following fields:
        %		- VariableName : char - unique identifier for the QOI
        %		- DisplayName : char - name displayed in GUI
        %		- Description : char - description of the QOI
        %		- Unit : char - unit of measurement
        %		- LowerLimit : double - lower limit constraint
        %		- UpperLimit : double - upper limit constraint
        %		- ColorWhenViolated : (1,3) double - RGB color for violation
        %		- ViolatedText : char - text displayed when violated
        %		- ActiveStatus : logical - whether QOI is active (default: true)
        %
        %	QUANTATIESOFINTERESTS : struct array
        %
        %	See also set_quantities_of_interest,
        %	get_quantities_of_interest_names, get_quantities_of_interest_limits.
        QuantatiesOfInterests

        %DESIGNPARAMETERS Struct array of constant design parameter definitions
        %	DESIGNPARAMETERS is a struct array where each element represents one
        %	constant design parameter (system parameter). Each struct must
        %	contain the following fields:
        %		- VariableName : char - unique identifier for the parameter
        %		- DisplayName : char - name displayed in GUI
        %		- Description : char - description of the parameter
        %		- Unit : char - unit of measurement
        %		- Value : double - constant value of the parameter
        %
        %	DESIGNPARAMETERS : struct array
        %
        %	See also set_system_parameters, get_design_parameters.
        DesignParameters

        %PLOTDESIREDPAIRS Array of design variable index pairs for plots
        %	PLOTDESIREDPAIRS is a double array of size (nPairs, 2) where each
        %	row specifies a pair of design variable indices to plot as a 2D
        %	projection. The first column contains x-axis variable indices, the
        %	second column contains y-axis variable indices.
        %
        %	PLOTDESIREDPAIRS : (nPairs, 2) double
        %
        %	See also set_plot_desired_pairs, get_plot_desired_pairs,
        %	create_panel_solution_space_visualization.
        PlotDesiredPairs
    end

    methods
        function obj = SolutionSpaceBoxXrayDataManager(varargin)
        %SOLUTIONSPACEBOXXRAYDATAMANAGER Constructor
        %	SOLUTIONSPACEBOXXRAYDATAMANAGER creates a data manager object for
        %	the BoxXRay solution space exploration tool. The constructor accepts
        %	optional design variables, quantities of interest, design parameters,
        %	and plot configurations, as well as any public property name-value
        %	pairs.
        %
        %	OBJ = SOLUTIONSPACEBOXXRAYDATAMANAGER creates an empty data manager
        %	object with default property values.
        %
        %	OBJ = SOLUTIONSPACEBOXXRAYDATAMANAGER(DESIGNVARIABLES) initializes
        %	the data manager with design variables specified in DESIGNVARIABLES.
        %
        %	OBJ = SOLUTIONSPACEBOXXRAYDATAMANAGER(DESIGNVARIABLES,
        %	QUANTATIESOFINTERESTS) also initializes quantities of interest.
        %
        %	OBJ = SOLUTIONSPACEBOXXRAYDATAMANAGER(DESIGNVARIABLES,
        %	QUANTATIESOFINTERESTS, DESIGNPARAMETERS) also initializes design
        %	parameters.
        %
        %	OBJ = SOLUTIONSPACEBOXXRAYDATAMANAGER(DESIGNVARIABLES,
        %	QUANTATIESOFINTERESTS, DESIGNPARAMETERS, PLOTDESIREDPAIRS) also
        %	initializes plot pair configurations.
        %
        %	OBJ = SOLUTIONSPACEBOXXRAYDATAMANAGER(...,NAME,VALUE,...) allows
        %	setting any public property using name-value pair arguments. These
        %	are set after the optional positional arguments.
        %
        %	Inputs:
        %		- DESIGNVARIABLES : struct array (optional)
        %			Array of design variable structures, each containing
        %			VariableName, DisplayName, Description, Unit,
        %			DesignSpaceLowerBound, DesignSpaceUpperBound,
        %			BoxLowerBound, BoxUpperBound
        %		- QUANTATIESOFINTERESTS : struct array (optional)
        %			Array of QOI structures, each containing VariableName,
        %			DisplayName, Description, Unit, LowerLimit, UpperLimit,
        %			ColorWhenViolated, ViolatedText
        %		- DESIGNPARAMETERS : struct array (optional)
        %			Array of parameter structures, each containing
        %			VariableName, DisplayName, Description, Unit, Value
        %		- PLOTDESIREDPAIRS : struct array OR cell array OR (nPairs,2)
        %			double (optional)
        %			Plot pair configurations in struct, cell, or numeric format
        %		- NAME,VALUE,... : name-value pairs (optional)
        %			Any public property name-value pairs
        %
        %	Outputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %
        %	See also set_design_variables, set_quantities_of_interest,
        %	set_system_parameters, set_plot_desired_pairs, set.

            parser = inputParser;
            parser.KeepUnmatched = true;
            parser.addOptional('DesignVariables',[],@(x)isstruct(x));
            parser.addOptional('QuantatiesOfInterests',[],@(x)isstruct(x));
            parser.addOptional('DesignParameters',[],@(x)isstruct(x));
            parser.addOptional('PlotDesiredPairs',[],@(x)isstruct(x));
            parser.parse(varargin{:});

            obj.DesignVariables = [];
            if(~isempty(parser.Results.DesignVariables))
                obj.set_design_variables(parser.Results.DesignVariables);
            end

            obj.QuantatiesOfInterests = [];
            if(~isempty(parser.Results.QuantatiesOfInterests))
                obj.set_quantities_of_interest(parser.Results.QuantatiesOfInterests);
            end

            obj.DesignParameters = [];
            if(~isempty(parser.Results.DesignParameters))
                obj.set_system_parameters(parser.Results.DesignParameters);
            end

            obj.PlotDesiredPairs = [];
            if(~isempty(parser.Results.PlotDesiredPairs))
                obj.set_plot_desired_pairs(parser.Results.PlotDesiredPairs);
            end

            extraOptions = namedargs2cell(parser.Unmatched);
            obj.set(extraOptions{:});
        end
        

        %% Setters (initialization)
        function set_design_variables(obj, varargin)
        %SET_DESIGN_VARIABLES Initialize and validate design variables
        %	SET_DESIGN_VARIABLES sets the design variables for the data manager
        %	and validates that all required fields are present. Each design
        %	variable must contain VariableName, DisplayName, Description, Unit,
        %	DesignSpaceLowerBound, DesignSpaceUpperBound, BoxLowerBound, and
        %	BoxUpperBound fields.
        %
        %	OBJ.SET_DESIGN_VARIABLES(DESIGNVARIABLES) sets the design variables
        %	from the struct array DESIGNVARIABLES. An error is thrown if any
        %	required field is missing.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- DESIGNVARIABLES : struct array
        %			Array of design variable structures, each containing:
        %			VariableName, DisplayName, Description, Unit,
        %			DesignSpaceLowerBound, DesignSpaceUpperBound,
        %			BoxLowerBound, BoxUpperBound
        %
        %	Outputs:
        %		None (DesignVariables property is updated)
        %
        %	See also get_design_variable_names, get_design_box,
        %	get_design_space.

            parser = inputParser;
            parser.addRequired('DesignVariables',@(x)isstruct(x));
            parser.parse(varargin{:});

            % verify that the design variables are valid
            expectedFields = {'VariableName', 'DisplayName', 'Description', 'Unit', 'DesignSpaceLowerBound', 'DesignSpaceUpperBound', 'BoxLowerBound', 'BoxUpperBound'};
            for i=1:numel(parser.Results.DesignVariables)
                for j=1:numel(expectedFields)
                    if(~isfield(parser.Results.DesignVariables(i), expectedFields{j}))
                        error('Design variable %d is missing the field %s', i, expectedFields{j});
                    end
                end
            end
            
            obj.DesignVariables = parser.Results.DesignVariables;
        end

        function set_quantities_of_interest(obj, varargin)
        %SET_QUANTITIES_OF_INTEREST Initialize and validate QOIs
        %	SET_QUANTITIES_OF_INTEREST sets the quantities of interest (QOIs)
        %	for the data manager and validates that all required fields are
        %	present. Each QOI must contain VariableName, DisplayName,
        %	Description, Unit, LowerLimit, UpperLimit, ColorWhenViolated, and
        %	ViolatedText fields. If ActiveStatus is not present, it defaults to
        %	true.
        %
        %	OBJ.SET_QUANTITIES_OF_INTEREST(QUANTATIESOFINTERESTS) sets the QOIs
        %	from the struct array QUANTATIESOFINTERESTS. An error is thrown if
        %	any required field is missing.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- QUANTATIESOFINTERESTS : struct array
        %			Array of QOI structures, each containing: VariableName,
        %			DisplayName, Description, Unit, LowerLimit, UpperLimit,
        %			ColorWhenViolated, ViolatedText. ActiveStatus is optional
        %			(default: true).
        %
        %	Outputs:
        %		None (QuantatiesOfInterests property is updated)
        %
        %	See also get_quantities_of_interest_names,
        %	get_quantities_of_interest_limits,
        %	get_quantities_of_interest_active_status.

            parser = inputParser;
            parser.addRequired('QuantatiesOfInterests',@(x)isstruct(x));
            parser.parse(varargin{:});

            % verify that the quantities of interests are valid
            expectedFields = {'VariableName', 'DisplayName', 'Description', 'Unit', 'LowerLimit', 'UpperLimit', 'ColorWhenViolated', 'ViolatedText'};
            for i=1:numel(parser.Results.QuantatiesOfInterests)
                for j=1:numel(expectedFields)
                    if(~isfield(parser.Results.QuantatiesOfInterests(i), expectedFields{j}))
                        error('Quantity of interest %d is missing the field %s', i, expectedFields{j});
                    end
                end
            end
            
            obj.QuantatiesOfInterests = parser.Results.QuantatiesOfInterests;
            for i=1:numel(obj.QuantatiesOfInterests)
                if(~isfield(obj.QuantatiesOfInterests(i), 'ActiveStatus'))
                    obj.QuantatiesOfInterests(i).ActiveStatus = true;
                end
            end
        end

        function set_system_parameters(obj, varargin)
        %SET_SYSTEM_PARAMETERS Initialize and validate design parameters
        %	SET_SYSTEM_PARAMETERS sets the constant design parameters (system
        %	parameters) for the data manager and validates that all required
        %	fields are present. Each parameter must contain VariableName,
        %	DisplayName, Description, Unit, and Value fields.
        %
        %	OBJ.SET_SYSTEM_PARAMETERS(DESIGNPARAMETERS) sets the design
        %	parameters from the struct array DESIGNPARAMETERS. An error is
        %	thrown if any required field is missing.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- DESIGNPARAMETERS : struct array
        %			Array of parameter structures, each containing:
        %			VariableName, DisplayName, Description, Unit, Value
        %
        %	Outputs:
        %		None (DesignParameters property is updated)
        %
        %	See also get_design_parameters.

            parser = inputParser;
            parser.addRequired('DesignParameters',@(x)isstruct(x));
            parser.parse(varargin{:});

            % verify that the design parameters are valid
            expectedFields = {'VariableName', 'DisplayName', 'Description', 'Unit', 'Value'};
            for i=1:numel(parser.Results.DesignParameters)
                for j=1:numel(expectedFields)
                    if(~isfield(parser.Results.DesignParameters(i), expectedFields{j}))
                        error('Design parameter %d is missing the field %s', i, expectedFields{j});
                    end
                end
            end
            
            obj.DesignParameters = parser.Results.DesignParameters;
        end

        function set_plot_desired_pairs(obj, varargin)
        %SET_PLOT_DESIRED_PAIRS Initialize plot pair configurations
        %	SET_PLOT_DESIRED_PAIRS sets the plot pair configurations for 2D
        %	projection plots. The input can be in numeric format (array of
        %	variable indices), struct format (array of structs with
        %	DesignVariableName cell arrays), or cell format (cell array with
        %	variable names). The output is always converted to numeric format
        %	(nPairs x 2 array of variable indices).
        %
        %	OBJ.SET_PLOT_DESIRED_PAIRS(PLOTDESIREDPAIRS) sets the plot pairs
        %	from PLOTDESIREDPAIRS. If the input is in struct or cell format,
        %	variable names are mapped to indices using the current
        %	DesignVariables.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- PLOTDESIREDPAIRS : (nPairs,2) double OR struct array OR cell
        %			array
        %			Numeric format: array where each row is [xIndex, yIndex]
        %			Struct format: array where each element has
        %			DesignVariableName{1} and DesignVariableName{2} fields
        %			Cell format: cell array where each row is {xName, yName}
        %
        %	Outputs:
        %		None (PlotDesiredPairs property is updated to numeric format)
        %
        %	See also get_plot_desired_pairs,
        %	create_panel_solution_space_visualization.

            parser = inputParser;
            parser.addRequired('PlotDesiredPairs',@(x)isstruct(x) || iscell(x) || isnumeric(x));
            parser.parse(varargin{:});

            if(isnumeric(parser.Results.PlotDesiredPairs) && size(parser.Results.PlotDesiredPairs,2) == 2)
                % already in numeric format: pair(i,:) = [x,y]
                plotDesiredPairs = parser.Results.PlotDesiredPairs;
            else
                designVariableIndexMapper = containers.Map;
                for i=1:size(obj.DesignVariables,2)
                    designVariableIndexMapper(obj.DesignVariables(i).VariableName) = i;
                end

                if(isstruct(parser.Results.PlotDesiredPairs))
                    % struct format: pair(i) = {xName,yName}
                    nDesiredPairs = numel(parser.Results.PlotDesiredPairs);
                    plotDesiredPairs = nan(nDesiredPairs,2);
                    for plotIdx = 1:nDesiredPairs
                        plotDesiredPairs(plotIdx, :) = [...
                            designVariableIndexMapper(parser.Results.PlotDesiredPairs(plotIdx).DesignVariableName{1}),
                            designVariableIndexMapper(parser.Results.PlotDesiredPairs(plotIdx).DesignVariableName{2})];  % Fill in the rows 
                    end
                else
                    % cell format: pair{i,1} = xName, pair{i,2} = yName
                    nDesiredPairs = size(parser.Results.PlotDesiredPairs,1);
                    plotDesiredPairs = nan(nDesiredPairs,2);
                    for plotIdx = 1:nDesiredPairs
                        plotDesiredPairs(plotIdx, :) = [...
                            designVariableIndexMapper(parser.Results.PlotDesiredPairs{plotIdx,1}),
                            designVariableIndexMapper(parser.Results.PlotDesiredPairs{plotIdx,2})];  % Fill in the rows 
                    end
                end
            end
            
            obj.PlotDesiredPairs = plotDesiredPairs;
        end

        function set.SystemEvaluation(obj, newValue)
        %SET.SYSTEMEVALUATION Property setter for SystemEvaluation
        %	SET.SYSTEMEVALUATION validates that the new value is a valid system
        %	evaluation object or function handle before setting the property.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- NEWVALUE : function_handle OR BottomUpMappingBase OR
        %		DesignEvaluatorBase
        %
        %	Outputs:
        %		None (SystemEvaluation property is updated if valid)
        %
        %	See also SystemEvaluation, BottomUpMappingBase,
        %	DesignEvaluatorBase.

            if(isa(newValue,'function_handle')||isa(newValue,'BottomUpMappingBase')||isa(newValue,'DesignEvaluatorBase'))
                obj.SystemEvaluation = newValue;
            else
                error('SystemEvaluation must be a function handle, BottomUpMappingBase, or DesignEvaluatorBase');
            end
        end

        function set(obj, varargin)
        %SET Set multiple properties using name-value pairs
        %	SET allows setting multiple public properties of the data manager
        %	using name-value pair arguments. This method provides a convenient
        %	way to configure multiple properties at once.
        %
        %	OBJ.SET(NAME1,VALUE1,NAME2,VALUE2,...) sets the properties
        %	specified by NAME1, NAME2, etc. to the corresponding values VALUE1,
        %	VALUE2, etc.
        %
        %	OBJ.SET(STRUCT) sets properties from a struct where field names are
        %	property names and field values are property values.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- NAME1,VALUE1,NAME2,VALUE2,... : name-value pairs
        %			Property names and values to set
        %
        %	Outputs:
        %		None (properties are updated)
        %
        %	See also SolutionSpaceBoxXrayDataManager.

            parser = inputParser;
            parser.KeepUnmatched = true;
            parser.StructExpand = true;
            parser.parse(varargin{:});

            fields = fieldnames(parser.Unmatched);
            nFields = length(fields);
            for i=1:nFields
                obj.(fields{i}) = parser.Unmatched.(fields{i});
            end
        end


        %% Setters (updates)
        function update_design_box_lower_bounds(obj, newValue, variableIndex)
        %UPDATE_DESIGN_BOX_LOWER_BOUNDS Update solution box lower bounds
        %	UPDATE_DESIGN_BOX_LOWER_BOUNDS updates the lower bounds of the
        %	solution box for one or more design variables. If variableIndex is
        %	not provided, all design variables are updated.
        %
        %	OBJ.UPDATE_DESIGN_BOX_LOWER_BOUNDS(NEWVALUE) updates the lower
        %	bounds for all design variables using values from NEWVALUE.
        %
        %	OBJ.UPDATE_DESIGN_BOX_LOWER_BOUNDS(NEWVALUE, VARIABLEINDEX) updates
        %	the lower bounds only for design variables specified in
        %	VARIABLEINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- NEWVALUE : (1, nVars) double OR (1, nSelected) double
        %			New lower bound values. If VARIABLEINDEX is provided, must
        %			match length of VARIABLEINDEX.
        %		- VARIABLEINDEX : (1, nSelected) integer (optional)
        %			Indices of design variables to update. Default: all variables
        %
        %	Outputs:
        %		None (DesignVariables property is updated)
        %
        %	See also update_design_box_upper_bounds, get_design_box.

            if(nargin < 3 || isempty(variableIndex))
                variableIndex = 1:length(obj.DesignVariables);
            end

            for i = 1:length(variableIndex)
                obj.DesignVariables(variableIndex(i)).BoxLowerBound = newValue(i);
            end
        end

        function update_design_box_upper_bounds(obj, newValue, variableIndex)
        %UPDATE_DESIGN_BOX_UPPER_BOUNDS Update solution box upper bounds
        %	UPDATE_DESIGN_BOX_UPPER_BOUNDS updates the upper bounds of the
        %	solution box for one or more design variables. If variableIndex is
        %	not provided, all design variables are updated.
        %
        %	OBJ.UPDATE_DESIGN_BOX_UPPER_BOUNDS(NEWVALUE) updates the upper
        %	bounds for all design variables using values from NEWVALUE.
        %
        %	OBJ.UPDATE_DESIGN_BOX_UPPER_BOUNDS(NEWVALUE, VARIABLEINDEX) updates
        %	the upper bounds only for design variables specified in
        %	VARIABLEINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- NEWVALUE : (1, nVars) double OR (1, nSelected) double
        %			New upper bound values. If VARIABLEINDEX is provided, must
        %			match length of VARIABLEINDEX.
        %		- VARIABLEINDEX : (1, nSelected) integer (optional)
        %			Indices of design variables to update. Default: all variables
        %
        %	Outputs:
        %		None (DesignVariables property is updated)
        %
        %	See also update_design_box_lower_bounds, get_design_box.

            if(nargin < 3 || isempty(variableIndex))
                variableIndex = 1:length(obj.DesignVariables);
            end
            for i = 1:length(variableIndex)
                obj.DesignVariables(variableIndex(i)).BoxUpperBound = newValue(i);
            end
        end

        function update_design_space_lower_bounds(obj, newValue, variableIndex)
        %UPDATE_DESIGN_SPACE_LOWER_BOUNDS Update design space lower bounds
        %	UPDATE_DESIGN_SPACE_LOWER_BOUNDS updates the lower bounds of the
        %	design space for one or more design variables. If variableIndex is
        %	not provided, all design variables are updated.
        %
        %	OBJ.UPDATE_DESIGN_SPACE_LOWER_BOUNDS(NEWVALUE) updates the lower
        %	bounds for all design variables using values from NEWVALUE.
        %
        %	OBJ.UPDATE_DESIGN_SPACE_LOWER_BOUNDS(NEWVALUE, VARIABLEINDEX)
        %	updates the lower bounds only for design variables specified in
        %	VARIABLEINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- NEWVALUE : (1, nVars) double OR (1, nSelected) double
        %			New lower bound values. If VARIABLEINDEX is provided, must
        %			match length of VARIABLEINDEX.
        %		- VARIABLEINDEX : (1, nSelected) integer (optional)
        %			Indices of design variables to update. Default: all variables
        %
        %	Outputs:
        %		None (DesignVariables property is updated)
        %
        %	See also update_design_space_upper_bounds, get_design_space.

            if(nargin < 3 || isempty(variableIndex))
                variableIndex = 1:length(obj.DesignVariables);
            end
            
            for i = 1:length(variableIndex)
                obj.DesignVariables(variableIndex(i)).DesignSpaceLowerBound = newValue(i);
            end
        end

        function update_design_space_upper_bounds(obj, newValue, variableIndex)
        %UPDATE_DESIGN_SPACE_UPPER_BOUNDS Update design space upper bounds
        %	UPDATE_DESIGN_SPACE_UPPER_BOUNDS updates the upper bounds of the
        %	design space for one or more design variables. If variableIndex is
        %	not provided, all design variables are updated.
        %
        %	OBJ.UPDATE_DESIGN_SPACE_UPPER_BOUNDS(NEWVALUE) updates the upper
        %	bounds for all design variables using values from NEWVALUE.
        %
        %	OBJ.UPDATE_DESIGN_SPACE_UPPER_BOUNDS(NEWVALUE, VARIABLEINDEX)
        %	updates the upper bounds only for design variables specified in
        %	VARIABLEINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- NEWVALUE : (1, nVars) double OR (1, nSelected) double
        %			New upper bound values. If VARIABLEINDEX is provided, must
        %			match length of VARIABLEINDEX.
        %		- VARIABLEINDEX : (1, nSelected) integer (optional)
        %			Indices of design variables to update. Default: all variables
        %
        %	Outputs:
        %		None (DesignVariables property is updated)
        %
        %	See also update_design_space_lower_bounds, get_design_space.

            if(nargin < 3 || isempty(variableIndex))
                variableIndex = 1:length(obj.DesignVariables);
            end

            for i = 1:length(variableIndex)
                obj.DesignVariables(variableIndex(i)).DesignSpaceUpperBound = newValue(i);
            end
        end	

        function update_points_per_figure(obj, newValue) % New Addition

            obj.NumberOfSamplesPerPlot = newValue;

        end

        function update_quantities_of_interest_lower_limits(obj, newValue, quantityOfInterestIndex)
        %UPDATE_QUANTITIES_OF_INTEREST_LOWER_LIMITS Update QOI lower limits
        %	UPDATE_QUANTITIES_OF_INTEREST_LOWER_LIMITS updates the lower limit
        %	constraints for one or more quantities of interest. If
        %	quantityOfInterestIndex is not provided, all QOIs are updated.
        %
        %	OBJ.UPDATE_QUANTITIES_OF_INTEREST_LOWER_LIMITS(NEWVALUE) updates
        %	the lower limits for all QOIs using values from NEWVALUE.
        %
        %	OBJ.UPDATE_QUANTITIES_OF_INTEREST_LOWER_LIMITS(NEWVALUE,
        %	QUANTITYOFINTERESTINDEX) updates the lower limits only for QOIs
        %	specified in QUANTITYOFINTERESTINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- NEWVALUE : (1, nQOIs) double OR (1, nSelected) double
        %			New lower limit values. If QUANTITYOFINTERESTINDEX is
        %			provided, must match length of QUANTITYOFINTERESTINDEX.
        %		- QUANTITYOFINTERESTINDEX : (1, nSelected) integer (optional)
        %			Indices of QOIs to update. Default: all QOIs
        %
        %	Outputs:
        %		None (QuantatiesOfInterests property is updated)
        %
        %	See also update_quantities_of_interest_upper_limits,
        %	get_quantities_of_interest_limits.

            if(nargin < 3 || isempty(quantityOfInterestIndex))
                quantityOfInterestIndex = 1:length(obj.QuantatiesOfInterests);
            end
            
            for i = 1:length(quantityOfInterestIndex)
                obj.QuantatiesOfInterests(quantityOfInterestIndex(i)).LowerLimit = newValue(i);
            end
        end

        function update_quantities_of_interest_upper_limits(obj, newValue, quantityOfInterestIndex)
        %UPDATE_QUANTITIES_OF_INTEREST_UPPER_LIMITS Update QOI upper limits
        %	UPDATE_QUANTITIES_OF_INTEREST_UPPER_LIMITS updates the upper limit
        %	constraints for one or more quantities of interest. If
        %	quantityOfInterestIndex is not provided, all QOIs are updated.
        %
        %	OBJ.UPDATE_QUANTITIES_OF_INTEREST_UPPER_LIMITS(NEWVALUE) updates
        %	the upper limits for all QOIs using values from NEWVALUE.
        %
        %	OBJ.UPDATE_QUANTITIES_OF_INTEREST_UPPER_LIMITS(NEWVALUE,
        %	QUANTITYOFINTERESTINDEX) updates the upper limits only for QOIs
        %	specified in QUANTITYOFINTERESTINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- NEWVALUE : (1, nQOIs) double OR (1, nSelected) double
        %			New upper limit values. If QUANTITYOFINTERESTINDEX is
        %			provided, must match length of QUANTITYOFINTERESTINDEX.
        %		- QUANTITYOFINTERESTINDEX : (1, nSelected) integer (optional)
        %			Indices of QOIs to update. Default: all QOIs
        %
        %	Outputs:
        %		None (QuantatiesOfInterests property is updated)
        %
        %	See also update_quantities_of_interest_lower_limits,
        %	get_quantities_of_interest_limits.

            if(nargin < 3 || isempty(quantityOfInterestIndex))
                quantityOfInterestIndex = 1:length(obj.QuantatiesOfInterests);
            end

            for i = 1:length(quantityOfInterestIndex)
                obj.QuantatiesOfInterests(quantityOfInterestIndex(i)).UpperLimit = newValue(i);
            end
        end

        function update_quantities_of_interest_active_status(obj, newStatus, quantityOfInterestIndex)
        %UPDATE_QUANTITIES_OF_INTEREST_ACTIVE_STATUS Toggle QOI active status
        %	UPDATE_QUANTITIES_OF_INTEREST_ACTIVE_STATUS updates the active
        %	status (enabled/disabled) for one or more quantities of interest.
        %	If quantityOfInterestIndex is not provided, all QOIs are updated.
        %	Active QOIs are considered during solution space evaluation and
        %	optimization, while inactive QOIs are ignored.
        %
        %	OBJ.UPDATE_QUANTITIES_OF_INTEREST_ACTIVE_STATUS(NEWSTATUS) updates
        %	the active status for all QOIs using values from NEWSTATUS.
        %
        %	OBJ.UPDATE_QUANTITIES_OF_INTEREST_ACTIVE_STATUS(NEWSTATUS,
        %	QUANTITYOFINTERESTINDEX) updates the active status only for QOIs
        %	specified in QUANTITYOFINTERESTINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- NEWSTATUS : (1, nQOIs) logical OR (1, nSelected) logical OR
        %		(1,1) logical
        %			New active status values (true = active, false = inactive).
        %			If QUANTITYOFINTERESTINDEX is provided, must match length
        %			of QUANTITYOFINTERESTINDEX or be scalar.
        %		- QUANTITYOFINTERESTINDEX : (1, nSelected) integer (optional)
        %			Indices of QOIs to update. Default: all QOIs
        %
        %	Outputs:
        %		None (QuantatiesOfInterests property is updated)
        %
        %	See also get_quantities_of_interest_active_status.

            if(nargin < 3 || isempty(quantityOfInterestIndex))
                quantityOfInterestIndex = 1:length(obj.QuantatiesOfInterests);
            end

            for i = 1:length(quantityOfInterestIndex)
                obj.QuantatiesOfInterests(quantityOfInterestIndex(i)).ActiveStatus = logical(newStatus);
            end
        end

        function update_quantities_of_interest_color_when_violated(obj, newColor, quantityOfInterestIndex)
        %UPDATE_QUANTITIES_OF_INTEREST_COLOR_WHEN_VIOLATED Update QOI violation colors
        %	UPDATE_QUANTITIES_OF_INTEREST_COLOR_WHEN_VIOLATED updates the RGB
        %	color used to indicate violations for one or more quantities of
        %	interest. If quantityOfInterestIndex is not provided, all QOIs are
        %	updated.
        %
        %	OBJ.UPDATE_QUANTITIES_OF_INTEREST_COLOR_WHEN_VIOLATED(NEWCOLOR)
        %	updates the violation colors for all QOIs using colors from
        %	NEWCOLOR.
        %
        %	OBJ.UPDATE_QUANTITIES_OF_INTEREST_COLOR_WHEN_VIOLATED(NEWCOLOR,
        %	QUANTITYOFINTERESTINDEX) updates the violation colors only for QOIs
        %	specified in QUANTITYOFINTERESTINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- NEWCOLOR : (nQOIs, 3) double OR (nSelected, 3) double
        %			RGB color values. Each row is [R, G, B] with values in
        %			[0, 1]. If QUANTITYOFINTERESTINDEX is provided, must
        %			match length of QUANTITYOFINTERESTINDEX.
        %		- QUANTITYOFINTERESTINDEX : (1, nSelected) integer (optional)
        %			Indices of QOIs to update. Default: all QOIs
        %
        %	Outputs:
        %		None (QuantatiesOfInterests property is updated)
        %
        %	See also get_quantities_of_interest_colors_when_violated.

            if(nargin < 3 || isempty(quantityOfInterestIndex))
                quantityOfInterestIndex = 1:length(obj.QuantatiesOfInterests);
            end

            for i = 1:length(quantityOfInterestIndex)
                obj.QuantatiesOfInterests(quantityOfInterestIndex(i)).ColorWhenViolated = newColor(i,:);
            end
        end

        function update_design_parameters(obj, newValue, designParametersIndex) % New Addition
        %UPDATE_QUANTITIES_OF_INTEREST_LOWER_LIMITS Update lower limit values for QOIs
        %   OBJ.UPDATE_QUANTITIES_OF_INTEREST_LOWER_LIMITS(NEWVALUE) updates the
        %   lower limits for all quantities of interest (QOIs) using the numeric
        %   array NEWVALUE.
        %
        %   OBJ.UPDATE_QUANTITIES_OF_INTEREST_LOWER_LIMITS(NEWVALUE, QOIINDEX)
        %   updates only the QOIs specified by the integer indices in QOIINDEX.
        %
        %   Inputs:
        %       - OBJ : SolutionSpaceBoxXrayDataManager
        %       - NEWVALUE : numeric array (1×nQOIs or 1×nSelected)
        %           New lower limit values. Must match the length of QOIINDEX if
        %           provided.
        %       - QOIINDEX : (1×nSelected) integer (optional)
        %           Indices of QOIs to update. Default: all QOIs.
        %
        %   Outputs:
        %       None (the QuantatiesOfInterests property is updated in-place)
        %
        %   Notes:
        %       - If QOIINDEX is omitted, all QOIs are updated.
        %       - Length of NEWVALUE must match the number of indices being updated.
        %
        %   See also update_design_parameters_comment, 
        %            get_design_parameters.

            if isempty(newValue)
                obj.DesignParameters = [];
                return
            end

            if(nargin < 3 || isempty(designParametersIndex))
                designParametersIndex = 1:length(obj.DesignParameters);
            end
            
            for i = 1:length(designParametersIndex)
                obj.DesignParameters(designParametersIndex(i)).Value = newValue(i);
            end
        end


        %% Getters
        function designVariableNames = get_design_variable_names(obj)
        %GET_DESIGN_VARIABLE_NAMES Get array of design variable names
        %	GET_DESIGN_VARIABLE_NAMES returns a cell array containing the
        %	VariableName field from each design variable structure.
        %
        %	DESIGNVARIABLENAMES = OBJ.GET_DESIGN_VARIABLE_NAMES returns a cell
        %	array of design variable names.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %
        %	Outputs:
        %		- DESIGNVARIABLENAMES : (1, nVars) cell array of char
        %			Array of design variable names
        %
        %	See also get_design_variable_display_names, set_design_variables.

            designVariableNames = {obj.DesignVariables.VariableName};
        end

        function designVariableDisplayNames = get_design_variable_display_names(obj)
        %GET_DESIGN_VARIABLE_DISPLAY_NAMES Get array of display names
        %	GET_DESIGN_VARIABLE_DISPLAY_NAMES returns a cell array containing
        %	the DisplayName field from each design variable structure. These
        %	names are used for GUI display purposes.
        %
        %	DESIGNVARIABLEDISPLAYNAMES = OBJ.GET_DESIGN_VARIABLE_DISPLAY_NAMES
        %	returns a cell array of design variable display names.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %
        %	Outputs:
        %		- DESIGNVARIABLEDISPLAYNAMES : (1, nVars) cell array of char
        %			Array of design variable display names
        %
        %	See also get_design_variable_names, set_design_variables.

            designVariableDisplayNames = {obj.DesignVariables.DisplayName};
        end

        function designVariableUnits = get_design_variable_units(obj) % New Addition
        %GET_DESIGN_VARIABLE_DISPLAY_NAMES Get array of display names
        %	GET_DESIGN_VARIABLE_DISPLAY_NAMES returns a cell array containing
        %	the DisplayName field from each design variable structure. These
        %	names are used for GUI display purposes.
        %
        %	DESIGNVARIABLEDISPLAYNAMES = OBJ.GET_DESIGN_VARIABLE_DISPLAY_NAMES
        %	returns a cell array of design variable display names.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %
        %	Outputs:
        %		- DESIGNVARIABLEDISPLAYNAMES : (1, nVars) cell array of char
        %			Array of design variable display names
        %
        %	See also get_design_variable_names, set_design_variables.

            designVariableUnits = {obj.DesignVariables.Unit};
        end
        
        function designBox = get_design_box(obj, variableIndex)
        %GET_DESIGN_BOX Get solution box bounds matrix
        %	GET_DESIGN_BOX returns a matrix containing the solution box bounds
        %	for all or selected design variables. The matrix has two rows: row 1
        %	contains lower bounds, row 2 contains upper bounds.
        %
        %	DESIGNBOX = OBJ.GET_DESIGN_BOX returns a (2, nVars) matrix with
        %	solution box bounds for all design variables.
        %
        %	DESIGNBOX = OBJ.GET_DESIGN_BOX(VARIABLEINDEX) returns bounds only
        %	for design variables specified in VARIABLEINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- VARIABLEINDEX : (1, nSelected) integer (optional)
        %			Indices of design variables to retrieve. Default: all
        %
        %	Outputs:
        %		- DESIGNBOX : (2, nVars) double OR (2, nSelected) double
        %			Matrix where row 1 is lower bounds, row 2 is upper bounds
        %
        %	See also get_design_space, update_design_box_lower_bounds,
        %	update_design_box_upper_bounds.

            designBox = [horzcat(obj.DesignVariables.BoxLowerBound); horzcat(obj.DesignVariables.BoxUpperBound)];

            if(nargin>=2 && ~isempty(variableIndex))
                designBox = designBox(:,variableIndex);
            end
        end

        function designSpace = get_design_space(obj, variableIndex)
        %GET_DESIGN_SPACE Get design space bounds matrix
        %	GET_DESIGN_SPACE returns a matrix containing the design space bounds
        %	for all or selected design variables. The matrix has two rows: row 1
        %	contains lower bounds, row 2 contains upper bounds.
        %
        %	DESIGNSPACE = OBJ.GET_DESIGN_SPACE returns a (2, nVars) matrix with
        %	design space bounds for all design variables.
        %
        %	DESIGNSPACE = OBJ.GET_DESIGN_SPACE(VARIABLEINDEX) returns bounds
        %	only for design variables specified in VARIABLEINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- VARIABLEINDEX : (1, nSelected) integer (optional)
        %			Indices of design variables to retrieve. Default: all
        %
        %	Outputs:
        %		- DESIGNSPACE : (2, nVars) double OR (2, nSelected) double
        %			Matrix where row 1 is lower bounds, row 2 is upper bounds
        %
        %	See also get_design_box, update_design_space_lower_bounds,
        %	update_design_space_upper_bounds.

            designSpace = [horzcat(obj.DesignVariables.DesignSpaceLowerBound); horzcat(obj.DesignVariables.DesignSpaceUpperBound)];

            if(nargin>=2 && ~isempty(variableIndex))
                designSpace = designSpace(:,variableIndex);
            end
        end

        function quantityOfInterestNames = get_quantities_of_interest_names(obj)
        %GET_QUANTITIES_OF_INTEREST_NAMES Get array of QOI names
        %	GET_QUANTITIES_OF_INTEREST_NAMES returns a cell array containing
        %	the VariableName field from each quantity of interest structure.
        %
        %	QUANTITYOFINTERESTNAMES = OBJ.GET_QUANTITIES_OF_INTEREST_NAMES
        %	returns a cell array of QOI names.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %
        %	Outputs:
        %		- QUANTITYOFINTERESTNAMES : (1, nQOIs) cell array of char
        %			Array of QOI names
        %
        %	See also get_quantities_of_interest_display_names,
        %	set_quantities_of_interest.

            quantityOfInterestNames = {obj.QuantatiesOfInterests.VariableName};
        end

        function quantitiesOfInterestDisplayNames = get_quantities_of_interest_display_names(obj)
        %GET_QUANTITIES_OF_INTEREST_DISPLAY_NAMES Get array of QOI display names
        %	GET_QUANTITIES_OF_INTEREST_DISPLAY_NAMES returns a cell array
        %	containing the DisplayName field from each quantity of interest
        %	structure. These names are used for GUI display purposes.
        %
        %	QUANTITIESOFINTERESTDISPLAYNAMES =
        %	OBJ.GET_QUANTITIES_OF_INTEREST_DISPLAY_NAMES returns a cell array
        %	of QOI display names.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %
        %	Outputs:
        %		- QUANTITIESOFINTERESTDISPLAYNAMES : (1, nQOIs) cell array of
        %		char
        %			Array of QOI display names
        %
        %	See also get_quantities_of_interest_names,
        %	set_quantities_of_interest.

            quantitiesOfInterestDisplayNames = {obj.QuantatiesOfInterests.DisplayName};
        end

        function quantitiesOfInterestUnits = get_quantities_of_interest_units(obj) % New Addition
        %GET_QUANTITIES_OF_INTEREST_DISPLAY_NAMES Get array of QOI display names
        %	GET_QUANTITIES_OF_INTEREST_DISPLAY_NAMES returns a cell array
        %	containing the DisplayName field from each quantity of interest
        %	structure. These names are used for GUI display purposes.
        %
        %	QUANTITIESOFINTERESTDISPLAYNAMES =
        %	OBJ.GET_QUANTITIES_OF_INTEREST_DISPLAY_NAMES returns a cell array
        %	of QOI display names.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %
        %	Outputs:
        %		- QUANTITIESOFINTERESTDISPLAYNAMES : (1, nQOIs) cell array of
        %		char
        %			Array of QOI display names
        %
        %	See also get_quantities_of_interest_names,
        %	set_quantities_of_interest.

            quantitiesOfInterestUnits = {obj.QuantatiesOfInterests.Unit};
        end

        function quantitiesOfInterestLimits = get_quantities_of_interest_limits(obj, quantityOfInterestIndex)
        %GET_QUANTITIES_OF_INTEREST_LIMITS Get QOI limits matrix
        %	GET_QUANTITIES_OF_INTEREST_LIMITS returns a matrix containing the
        %	lower and upper limit constraints for all or selected quantities of
        %	interest. The matrix has two rows: row 1 contains lower limits,
        %	row 2 contains upper limits.
        %
        %	QUANTITIESOFINTERESTLIMITS =
        %	OBJ.GET_QUANTITIES_OF_INTEREST_LIMITS returns a (2, nQOIs) matrix
        %	with QOI limits for all quantities of interest.
        %
        %	QUANTITIESOFINTERESTLIMITS =
        %	OBJ.GET_QUANTITIES_OF_INTEREST_LIMITS(QUANTITYOFINTERESTINDEX)
        %	returns limits only for QOIs specified in
        %	QUANTITYOFINTERESTINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- QUANTITYOFINTERESTINDEX : (1, nSelected) integer (optional)
        %			Indices of QOIs to retrieve. Default: all
        %
        %	Outputs:
        %		- QUANTITIESOFINTERESTLIMITS : (2, nQOIs) double OR (2,
        %		nSelected) double
        %			Matrix where row 1 is lower limits, row 2 is upper limits
        %
        %	See also update_quantities_of_interest_lower_limits,
        %	update_quantities_of_interest_upper_limits.

            quantitiesOfInterestLimits = [horzcat(obj.QuantatiesOfInterests.LowerLimit); horzcat(obj.QuantatiesOfInterests.UpperLimit)];

            if(nargin>=2 && ~isempty(quantityOfInterestIndex))
                quantitiesOfInterestLimits = quantitiesOfInterestLimits(:,quantityOfInterestIndex);
            end
        end

        function quantitiesOfInterestColors = get_quantities_of_interest_colors_when_violated(obj, quantityOfInterestIndex)
        %GET_QUANTITIES_OF_INTEREST_COLORS_WHEN_VIOLATED Get QOI violation colors
        %	GET_QUANTITIES_OF_INTEREST_COLORS_WHEN_VIOLATED returns a matrix
        %	containing the RGB colors used to indicate violations for all or
        %	selected quantities of interest. Each row contains [R, G, B] color
        %	values.
        %
        %	QUANTITIESOFINTERESTCOLORS =
        %	OBJ.GET_QUANTITIES_OF_INTEREST_COLORS_WHEN_VIOLATED returns a
        %	(nQOIs, 3) matrix with violation colors for all QOIs.
        %
        %	QUANTITIESOFINTERESTCOLORS =
        %	OBJ.GET_QUANTITIES_OF_INTEREST_COLORS_WHEN_VIOLATED(QUANTITYOFINTERESTINDEX)
        %	returns colors only for QOIs specified in
        %	QUANTITYOFINTERESTINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- QUANTITYOFINTERESTINDEX : (1, nSelected) integer (optional)
        %			Indices of QOIs to retrieve. Default: all
        %
        %	Outputs:
        %		- QUANTITIESOFINTERESTCOLORS : (nQOIs, 3) double OR (nSelected,
        %		3) double
        %			Matrix where each row is [R, G, B] color values in [0, 1]
        %
        %	See also update_quantities_of_interest_color_when_violated.

            quantitiesOfInterestColors = vertcat(obj.QuantatiesOfInterests.ColorWhenViolated);

            if(nargin>=2 && ~isempty(quantityOfInterestIndex))
                quantitiesOfInterestColors = quantitiesOfInterestColors(quantityOfInterestIndex,:);
            end
        end

        function designParameters = get_design_parameters(obj, designParameterIndex)
        %GET_DESIGN_PARAMETERS Get design parameter values array
        %	GET_DESIGN_PARAMETERS returns an array containing the Value field
        %	from each design parameter structure. If no design parameters are
        %	defined, an empty array is returned.
        %
        %	DESIGNPARAMETERS = OBJ.GET_DESIGN_PARAMETERS returns an array of
        %	design parameter values for all parameters.
        %
        %	DESIGNPARAMETERS = OBJ.GET_DESIGN_PARAMETERS(DESIGNPARAMETERINDEX)
        %	returns values only for parameters specified in
        %	DESIGNPARAMETERINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- DESIGNPARAMETERINDEX : (1, nSelected) integer (optional)
        %			Indices of parameters to retrieve. Default: all
        %
        %	Outputs:
        %		- DESIGNPARAMETERS : (1, nParams) double OR (1, nSelected) double
        %			OR []
        %			Array of design parameter values, or empty if none defined
        %
        %	See also set_system_parameters.

            if(isempty(obj.DesignParameters))
                designParameters = [];
                return;
            end

            designParameters = horzcat(obj.DesignParameters.Value);

            if(nargin>=2 && ~isempty(designParameterIndex))
                designParameters = designParameters(designParameterIndex);
            end
        end

        function designParametersComment = get_design_parameters_comment(obj, designParameterIndex) % New Addition
        %GET_DESIGN_PARAMETERS_COMMENT Retrieve design parameter comments
        %   GET_DESIGN_PARAMETERS_COMMENT returns an array containing the
        %   Description field from each entry of the DesignParameters struct
        %   array. If no design parameters are defined, an empty array is
        %   returned.
        %
        %   DESIGNPARAMETERSCOMMENT = OBJ.GET_DESIGN_PARAMETERS_COMMENT
        %   returns a cell array of description text for all defined design
        %   parameters.
        %
        %   DESIGNPARAMETERSCOMMENT =
        %   OBJ.GET_DESIGN_PARAMETERS_COMMENT(DESIGNPARAMETERINDEX) returns
        %   only the descriptions corresponding to the indices specified in
        %   DESIGNPARAMETERINDEX.
        %
        %   Inputs:
        %       - OBJ : SolutionSpaceBoxXrayDataManager
        %       - DESIGNPARAMETERINDEX : (1, nSelected) integer (optional)
        %           Indices of design parameters to retrieve. Default: all.
        %
        %   Outputs:
        %       - DESIGNPARAMETERSCOMMENT : (1, nParams) cell OR (1, nSelected) cell OR []
        %           Cell array of parameter description strings. Returns []
        %           if no design parameters are defined.
        %
        %   See also GET_DESIGN_PARAMETERS, SET_SYSTEM_PARAMETERS.
            if isempty(obj.DesignParameters)
                designParametersComment = [];
                return;
            end

            % Extract descriptions into a cell row vector
            designParametersComment = {obj.DesignParameters.Description};

            if nargin >= 2 && ~isempty(designParameterIndex)
                designParametersComment = designParametersComment(designParameterIndex);
            end
        end

        function plotDesiredPairs = get_plot_desired_pairs(obj)
        %GET_PLOT_DESIRED_PAIRS Get plot pair configuration array
        %	GET_PLOT_DESIRED_PAIRS returns the array of design variable index
        %	pairs for 2D projection plots. Each row specifies a pair [xIndex,
        %	yIndex] to plot.
        %
        %	PLOTDESIREDPAIRS = OBJ.GET_PLOT_DESIRED_PAIRS returns a (nPairs, 2)
        %	matrix of plot pair indices.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %
        %	Outputs:
        %		- PLOTDESIREDPAIRS : (nPairs, 2) double
        %			Matrix where each row is [xVariableIndex, yVariableIndex]
        %
        %	See also set_plot_desired_pairs,
        %	create_panel_solution_space_visualization.

            plotDesiredPairs = obj.PlotDesiredPairs;
        end

        function violatedText = get_quantities_of_interest_violated_text(obj, quantityOfInterestIndex)
        %GET_QUANTITIES_OF_INTEREST_VIOLATED_TEXT Get QOI violation text
        %	GET_QUANTITIES_OF_INTEREST_VIOLATED_TEXT returns a cell array
        %	containing the ViolatedText field from each quantity of interest
        %	structure. This text is displayed when a QOI constraint is
        %	violated.
        %
        %	VIOLATEDTEXT = OBJ.GET_QUANTITIES_OF_INTEREST_VIOLATED_TEXT returns
        %	a cell array of violation text for all QOIs.
        %
        %	VIOLATEDTEXT = OBJ.GET_QUANTITIES_OF_INTEREST_VIOLATED_TEXT(QUANTITYOFINTERESTINDEX)
        %	returns violation text only for QOIs specified in
        %	QUANTITYOFINTERESTINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- QUANTITYOFINTERESTINDEX : (1, nSelected) integer (optional)
        %			Indices of QOIs to retrieve. Default: all
        %
        %	Outputs:
        %		- VIOLATEDTEXT : (1, nQOIs) cell array of char OR (1, nSelected)
        %		cell array of char
        %			Array of violation text strings
        %
        %	See also set_quantities_of_interest.

            violatedText = {obj.QuantatiesOfInterests.ViolatedText};

            if(nargin>=2 && ~isempty(quantityOfInterestIndex))
                violatedText = violatedText(quantityOfInterestIndex);
            end
        end

        function quantitiesOfInterestActiveStatus = get_quantities_of_interest_active_status(obj, quantityOfInterestIndex)
        %GET_QUANTITIES_OF_INTEREST_ACTIVE_STATUS Get QOI active status
        %	GET_QUANTITIES_OF_INTEREST_ACTIVE_STATUS returns a logical array
        %	indicating which quantities of interest are currently active
        %	(enabled). Active QOIs are considered during solution space
        %	evaluation and optimization, while inactive QOIs are ignored.
        %
        %	QUANTITIESOFINTERESTACTIVESTATUS =
        %	OBJ.GET_QUANTITIES_OF_INTEREST_ACTIVE_STATUS returns a logical
        %	array of active status for all QOIs.
        %
        %	QUANTITIESOFINTERESTACTIVESTATUS =
        %	OBJ.GET_QUANTITIES_OF_INTEREST_ACTIVE_STATUS(QUANTITYOFINTERESTINDEX)
        %	returns active status only for QOIs specified in
        %	QUANTITYOFINTERESTINDEX.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %		- QUANTITYOFINTERESTINDEX : (1, nSelected) integer (optional)
        %			Indices of QOIs to retrieve. Default: all
        %
        %	Outputs:
        %		- QUANTITIESOFINTERESTACTIVESTATUS : (1, nQOIs) logical OR (1,
        %		nSelected) logical
        %			Logical array where true indicates active QOI
        %
        %	See also update_quantities_of_interest_active_status.

            quantitiesOfInterestActiveStatus = logical([obj.QuantatiesOfInterests.ActiveStatus]);

            if(nargin>=2 && ~isempty(quantityOfInterestIndex))
                quantitiesOfInterestActiveStatus = quantitiesOfInterestActiveStatus(quantityOfInterestIndex);
            end
        end

        function isEmptyDesignParameters = isDesignParametersEmpty(obj) % New Addition
        %IS_DESIGN_PARAMETERS_EMPTY Check if DesignParameters is empty
        %   IS_DESIGN_PARAMETERS_EMPTY returns a logical scalar indicating whether
        %   the DesignParameters property contains any entries.
        %
        %   TF = OBJ.IS_DESIGN_PARAMETERS_EMPTY returns true if the struct array
        %   DesignParameters is empty (0×0 struct), and false otherwise.
        %
        %   Since DesignParameters is a protected property, this method provides
        %   controlled external access to its emptiness status.
        %
        %   Inputs:
        %       - OBJ : SolutionSpaceBoxXrayDataManager
        %
        %   Outputs:
        %       - IsEmptyDesignParameters : logical scalar
        %           True if DesignParameters is empty, false otherwise.
        %
        %   See also get_quantities_of_interest_active_status.

            isEmptyDesignParameters = isempty(obj.DesignParameters);
        end

        function designParameterNames = get_design_parameters_names(obj) % New Addition
        %GET_DESIGN_PARAMETER_NAMES Get array of design parameter names
        %	GET_DESIGN_PARAMETER_NAMES returns a cell array containing
        %	the VariableName field from each design parameter structure.
        %
        %	SYSTEMPARAMETERNAMES = OBJ.GET_DESIGN_PARAMETER_NAMES
        %	returns a cell array of systemParameter names.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %
        %	Outputs:
        %		- DESIGNPARAMETERNAMES : (1, ndesignParameter) cell array of char
        %			Array of designParameter names
        %
        %	See also get_design_parameters_display_names,
        %	set_design_parameters.

            designParameterNames = {obj.DesignParameters.VariableName};
        end

        function designParameterDisplayNames = get_design_parameters_display_names(obj) % New Addition
        %GET_DESIGN_PARAMETER_DISPLAY_NAMES Get array of design parameter display names
        %	GET_DESIGN_PARAMETER_DISPLAY_NAMES returns a cell array
        %	containing the DisplayName field from each design parameter
        %	structure. These names are used for GUI display purposes.
        %
        %	DESIGNPARAMETERDISPLAYNAMES =
        %	OBJ.GET_DESIGN_PARAMETER_DISPLAY_NAMES returns a cell array
        %	of design parameter display names.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %
        %	Outputs:
        %		- DESIGNPARAMETERDISPLAYNAMES : (1, ndesignParameter) cell array of
        %		char
        %			Array of designParameter display names
        %
        %	See also get_design_parameters_names,
        %	set_design_parameters.

            designParameterDisplayNames = {obj.DesignParameters.DisplayName};
        end

        function designParameterUnits = get_design_parameters_unit(obj) % New Addition
        %GET_DESIGN_PARAMETER_DISPLAY_NAMES Get array of design parameter display names
        %	GET_DESIGN_PARAMETER_DISPLAY_NAMES returns a cell array
        %	containing the DisplayName field from each design parameter
        %	structure. These names are used for GUI display purposes.
        %
        %	DESIGNPARAMETERDISPLAYNAMES =
        %	OBJ.GET_DESIGN_PARAMETER_DISPLAY_NAMES returns a cell array
        %	of design parameter display names.
        %
        %	Inputs:
        %		- OBJ : SolutionSpaceBoxXrayDataManager
        %
        %	Outputs:
        %		- DESIGNPARAMETERDISPLAYNAMES : (1, ndesignParameter) cell array of
        %		char
        %			Array of designParameter display names
        %
        %	See also get_design_parameters_names,
        %	set_design_parameters.

            designParameterUnits = {obj.DesignParameters.Unit};
        end

        
    end
end
