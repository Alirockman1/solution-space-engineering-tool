function designTypeHandle = plot_design_space_projection_axis(axisHandle,plotData,varargin)
%PLOT_DESIGN_SPACE_PROJECTION_AXIS Plot design space projection on axis
%   PLOT_DESIGN_SPACE_PROJECTION_AXIS plots a 2D projection of the design space
%   on a given axis handle, showing design samples colored according to their
%   performance (good/bad) and physical feasibility status. The function also
%   displays the solution space box boundaries and interval markers for the
%   projected design variables.
%
%   DESIGNTYPEHANDLE = PLOT_DESIGN_SPACE_PROJECTION_AXIS(AXISHANDLE,PLOTDATA)
%   plots the design space projection on the axis AXISHANDLE using the data in
%   PLOTDATA structure with default plotting options.
%
%   DESIGNTYPEHANDLE = PLOT_DESIGN_SPACE_PROJECTION_AXIS(AXISHANDLE,PLOTDATA,
%   VARARGIN) allows specification of additional options through name-value
%   pairs:
%       - 'AxesLabels' : cell array of two strings for x and y axis labels.
%       Default: empty.
%       - 'MarkerColorsViolatedRequirements' : color specification for markers
%       when requirements are violated. Can be a single color or cell array of
%       colors for different requirements. Default: red from color palette.
%       - 'PlotIntervals' : logical flag indicating whether to plot dashed
%       interval lines showing the solution space box boundaries. Default: true.
%       - 'PlotOptionsGood' : cell array of plot options for good performance
%       points. Default: {'Linestyle', 'none', 'Marker', '.', 'Color', green}.
%       - 'PlotOptionsBad' : cell array of plot options for bad performance
%       points. Default: {'Linestyle', 'none', 'Marker', 'x'}.
%       - 'PlotOptionsPhysicallyInfeasible' : cell array of plot options for
%       physically infeasible points. Default: {'Linestyle', 'none', 'Marker',
%       '.', 'Color', grey}.
%       - 'PlotOptionsIntervals' : cell array of plot options for interval
%       lines. Default: {'LineStyle', '--', 'Color', 'k', 'Linewidth', 1.5}.
%       - 'PlotOptionsBox' : cell array of plot options for the solution box
%       contour. Default: {'Linestyle', '-', 'EdgeColor', 'k', 'Linewidth', 2.0}.
%       - 'AxisLabelsOptions' : cell array of name-value pairs specifying
%       options for the axis labels. Default: {'FontSize', 12}.
%       - 'FixPanning' : logical flag to disable panning and zooming on the
%       axis. Default: true.
%
%   Inputs:
%       - AXISHANDLE : Axes
%           -- handle to the axis where the plot will be created
%       - PLOTDATA : struct
%           -- structure containing design samples and evaluation results:
%           -- DesignSample : (nSample,2) double - design samples for the pair
%           -- RequirementViolated : (nSample,1) integer - requirement index
%           -- IsPhysicallyFeasible : (nSample,1) logical - feasibility flag
%           -- DesignSpaceLowerBound : (1,2) double - lower bounds
%           -- DesignSpaceUpperBound : (1,2) double - upper bounds
%           -- DesignBox : (2,2) double - solution space box bounds
%       - 'AxesLabels' : (1,2) cell array of char/string
%           -- labels for x and y axes
%       - 'MarkerColorsViolatedRequirements' : (1,1) char/string OR (1,nRequirement) cell OR (nRequirement,3) double
%           -- color(s) for violated requirement markers
%       - 'PlotIntervals' : (1,1) logical
%           -- flag to plot interval lines
%       - 'PlotOptionsGood' : (1,nOption) cell array
%           -- plot options for good performance points
%       - 'PlotOptionsBad' : (1,nOption) cell array
%           -- plot options for bad performance points
%       - 'PlotOptionsPhysicallyInfeasible' : (1,nOption) cell array
%           -- plot options for physically infeasible points
%       - 'PlotOptionsIntervals' : (1,nOption) cell array
%           -- plot options for interval lines
%       - 'PlotOptionsBox' : (1,nOption) cell array
%           -- plot options for solution box contour
%       - 'AxisLabelsOptions' : (1,nOption) cell array
%           -- options for the axis labels
%       - 'FixPanning' : (1,1) logical
%           -- flag to disable panning/zooming
%
%   Outputs:
%       - DESIGNTYPEHANDLE : struct
%           -- handles to plotted graphics objects:
%           -- GoodPerformance : Line handle for good performance points
%           -- PhysicallyInfeasible : Line handle for infeasible points
%           -- BadPerformance : (1,nRequirement) cell array of Line handles
%
%   See also evaluate_selective_design_space_projection,
%   plot_selective_design_space_projection, plot_design_box_2d.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2022-2025.
%   Copyright 2022-2025 Eduardo Rodrigues Della Noce
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

    parser = inputParser;
    parser.addParameter('AxesLabels',{},@(x)iscell(x));
    parser.addParameter('MarkerColorsViolatedRequirements',color_palette_tol('red'));
    parser.addParameter('PlotIntervals',true,@(x)islogical(x));
    parser.addParameter('PlotOptionsGood',{},@(x)iscell(x));
    parser.addParameter('PlotOptionsBad',{},@(x)iscell(x));
    parser.addParameter('PlotOptionsPhysicallyInfeasible',{},@(x)iscell(x));
    parser.addParameter('PlotOptionsIntervals',{},@iscell);
    parser.addParameter('PlotOptionsBox',{},@(x)iscell(x));
    parser.addParameter('FixPanning',true,@(x)islogical(x));
    parser.addParameter('AxisLabelsOptions',{},@(x)iscell(x));
    parser.parse(varargin{:});
    options = parser.Results;

    defaultPlotOptionsGood = {'Linestyle','none','Marker','.','Color',color_palette_tol('green'),'MarkerSize',10,'LineWidth',1.0};
    [~,plotOptionsGood] = merge_name_value_pair_argument(defaultPlotOptionsGood,options.PlotOptionsGood);

    defaultPlotOptionsBad = {'Linestyle','none','Marker','x','MarkerSize',8,'LineWidth',1.0};
    [~,plotOptionsBad] = merge_name_value_pair_argument(defaultPlotOptionsBad,options.PlotOptionsBad);

    defaultPlotOptionsPhysicallyInfeasible = {'Linestyle','none','Marker','o','Color',color_palette_tol('grey'),'MarkerSize',8,'LineWidth',1.0};
    [~,plotOptionsPhysicallyInfeasible] = merge_name_value_pair_argument(defaultPlotOptionsPhysicallyInfeasible,...
        options.PlotOptionsPhysicallyInfeasible);

    defaultPlotOptionsIntervals = {'LineStyle','--','Color','k','Linewidth',1.5};
    [~,plotOptionsIntervals] = merge_name_value_pair_argument(defaultPlotOptionsIntervals,options.PlotOptionsIntervals);

    defaultPlotOptionsBox = {'Linestyle','-','EdgeColor','k','Linewidth',2.0};
    [~,plotOptionBox] = merge_name_value_pair_argument(defaultPlotOptionsBox,options.PlotOptionsBox);

    defaultAxisLabelsOptions = {'FontSize',12};
    [~,axisLabelsOptions] = merge_name_value_pair_argument(defaultAxisLabelsOptions,options.AxisLabelsOptions);


    %% Extract Data
    designSample = plotData.DesignSample;
    isPhysicallyFeasible = plotData.IsPhysicallyFeasible;
    iRequirementViolated = plotData.RequirementViolated;
    designSpaceLowerBound = plotData.DesignSpaceLowerBound;
    designSpaceUpperBound = plotData.DesignSpaceUpperBound;
    designBox = plotData.DesignBox;
    

    isGoodPerformance = (iRequirementViolated==0);
    nRequirement = max(max(iRequirementViolated),size(options.MarkerColorsViolatedRequirements,1));

    designTypeHandle.GoodPerformance = matlab.graphics.GraphicsPlaceholder;
    designTypeHandle.PhysicallyInfeasible = matlab.graphics.GraphicsPlaceholder;
    designTypeHandle.BadPerformance = cell(1,nRequirement);
    

    %% Plotting
    activate_graphics_object(axisHandle);
    hold(axisHandle,'all');

    % axis lengths and labels
    axis(axisHandle,[...
        designSpaceLowerBound(1) ...
        designSpaceUpperBound(1) ...
        designSpaceLowerBound(2) ...
        designSpaceUpperBound(2)]);
    if(~isempty(options.AxesLabels))
        xlabel(axisHandle,options.AxesLabels{1},axisLabelsOptions{:});
        ylabel(axisHandle,options.AxesLabels{2},axisLabelsOptions{:});
    end
    grid(axisHandle,'off');
    drawnow;

    % physically infeasible designs
    if(any(~isPhysicallyFeasible))
        designTypeHandle.PhysicallyInfeasible = plot(axisHandle,...
            designSample(~isPhysicallyFeasible,1),...
            designSample(~isPhysicallyFeasible,2),...
            plotOptionsPhysicallyInfeasible{:});
    end
    
    % bad designs
    for i=1:nRequirement
        if(iscell(options.MarkerColorsViolatedRequirements))
            violateColor = options.MarkerColorsViolatedRequirements{i};
        elseif(size(options.MarkerColorsViolatedRequirements,1)==1)
            violateColor = options.MarkerColorsViolatedRequirements;
        else
            violateColor = options.MarkerColorsViolatedRequirements(i,:);
        end
        
        iViolated = find(iRequirementViolated==i);
        
        if(~isempty(iViolated))
            designTypeHandle.BadPerformance{i} = plot(axisHandle,...
                designSample(iViolated,1),...
                designSample(iViolated,2),...
                'Color',violateColor,...
                plotOptionsBad{:});
        else
            designTypeHandle.BadPerformance{i} = matlab.graphics.GraphicsPlaceholder;
        end
    end

    % good designs
    if(any(isGoodPerformance & isPhysicallyFeasible))
        designTypeHandle.GoodPerformance = plot(axisHandle,...
            designSample(isGoodPerformance & isPhysicallyFeasible,1),...
            designSample(isGoodPerformance & isPhysicallyFeasible,2),...
            plotOptionsGood{:});
    end
    
    % dashed box limits
    if(options.PlotIntervals)
        plot(axisHandle,...
            [designBox(1,1) designBox(1,1)],...
            [designSpaceLowerBound(2) designSpaceUpperBound(2)],...
            plotOptionsIntervals{:}); % vertical left line


        plot(axisHandle,...
            [designBox(2,1) designBox(2,1)],...
            [designSpaceLowerBound(2) designSpaceUpperBound(2)],...
            plotOptionsIntervals{:}); % vertical right line



        plot(axisHandle,...
            [designSpaceLowerBound(1) designSpaceUpperBound(1)],...
            [designBox(1,2) designBox(1,2)],...
            plotOptionsIntervals{:}); % horizontal lower line
        

        plot(axisHandle,...
            [designSpaceLowerBound(1) designSpaceUpperBound(1)],...
            [designBox(2,2) designBox(2,2)],...
            plotOptionsIntervals{:}); % horizontal upper line
    end

    % box contour
    plot_design_box_2d(axisHandle,designBox,plotOptionBox{:});

    % Fix axis to prevent panning
    if(options.FixPanning)
        pan(axisHandle,'off');
        pan().setAllowAxesPan(axisHandle,false);
        zoom(axisHandle,'off');
        zoom().setAllowAxesZoom(axisHandle,false);
    end
end
