function plot_design_intervals(graphicsHandle,designIntervals,varargin)
%PLOT_DESIGN_INTERVALS Visualize design intervals for multiple variables
%   PLOT_DESIGN_INTERVALS(GRAPHICSHANDLE,DESIGNINTERVALS) plots the lower
%   and upper bounds of design intervals for each design variable in the
%   axes specified by GRAPHICSHANDLE. Intervals are displayed as vertical
%   lines per variable and optional connecting corridor lines between the
%   lower and upper interval boundaries.
%
%   PLOT_DESIGN_INTERVALS(...,NAME,VALUE,...) accepts the following
%   name-value options (as used by the internal inputParser) and describes
%   how they affect the visualization:
%       - 'DesignSpaceLowerBound' : numeric or empty (default: []).
%           If provided, sets the lower bound of the design space for each
%           variable. Can be a scalar (applied to all variables) or a
%           vector with one entry per variable. If empty, the minimum value
%           of `designIntervals` is used per variable.
%       - 'DesignSpaceUpperBound' : numeric or empty (default: []).
%           Analogous to 'DesignSpaceLowerBound' but for upper bounds. If
%           empty, the maximum value of `designIntervals` is used per
%           variable.
%       - 'NormalizeIntervals' : logical (default: true).
%           When true, intervals and design-space bounds are normalized to
%           the [0,1] range for plotting using the design-space bounds.
%           When false, raw values from `designIntervals` and the design
%           space bounds are used as-is.
%       - 'VariableLabels' : cell (default: {}).
%           Cell array of strings to use as x-axis tick labels for each
%           variable. If empty, automatic LaTeX-style labels of the form
%           '$x_{i}$' are used.
%       - 'LabelOptions' : cell (default: {}).
%           Name-value pairs forwarded to the `set` call that applies x
%           tick label properties (e.g., 'FontSize', 'TickLabelInterpreter').
%       - 'TextFormatting' : char (default: ' %.g').
%           A sprintf-style format string used to format numeric text that
%           is printed next to the lower/upper bounds and interval values.
%       - 'TextOptions' : cell (default: {}).
%           Name-value pairs passed to `text` when drawing numeric values
%           (e.g., 'FontSize', 'HorizontalAlignment').
%       - 'PlotCorridor' : logical (default: true).
%           When true, draws lines connecting the lower bounds and the
%           upper bounds across variables (the corridor). When false, these
%           connecting lines are omitted.
%       - 'LineOptions' : cell (default: {}).
%           Base line property name-value pairs merged into other line
%           option groups. Useful to apply a shared style to multiple line
%           elements.
%       - 'CorridorOptions' : cell (default: {}).
%           Additional name-value pairs to style the corridor (connecting)
%           lines. Merged with 'LineOptions'.
%       - 'DesignSpaceOptions' : cell (default: {}).
%           Name-value pairs used to style the vertical lines representing
%           the full design-space range for each variable. Merged with
%           'LineOptions'.
%       - 'DesignIntervalsOptions' : cell (default: {}).
%           Name-value pairs used to style the vertical lines representing
%           the design intervals themselves (lower and upper interval bounds).
%
%   There is no return value; the function draws into the provided axes.
%
%   See also text, plot, xticks, set.

%   Developed at the Laboratory for Product Development and Lightweight
%   Design (LPL), Technical University of Munich (TUM), 2022-2025.
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
    % design space
    parser.addOptional('DesignSpaceLowerBound',[],@(x)isnumeric(x));
    parser.addOptional('DesignSpaceUpperBound',[],@(x)isnumeric(x));
    % plotting everything in the same scale
    parser.addParameter('NormalizeIntervals',true,@(x)islogical(x));
    % labels for design variables
    parser.addParameter('VariableLabels',{},@(x)iscell(x));
    parser.addParameter('LabelOptions',{},@(x)iscell(x));
    parser.addParameter('TextFormatting',' %.g',@(x)ischar(x));
    parser.addParameter('TextOptions',{},@(x)iscell(x));
    % corridor - connecting line between boundaries of the design intervals
    parser.addParameter('PlotCorridor',true,@(x)islogical(x));
    % options for lines
    parser.addParameter('LineOptions',{},@(x)iscell(x));
    parser.addParameter('CorridorOptions',{},@(x)iscell(x));
    parser.addParameter('DesignSpaceOptions',{},@(x)iscell(x));
    parser.addParameter('DesignIntervalsOptions',{},@(x)iscell(x));
    % parse
    parser.parse(varargin{:});

    labelDefaultOptions = {'TickLabelInterpreter','latex','FontSize',12};
    [~,labelOptions] = merge_name_value_pair_argument(labelDefaultOptions,parser.Results.LabelOptions);

    textDefaultOptions = {'FontSize',12,'HorizontalAlignment','left','VerticalAlignment','middle'};
    [~,textOptions] = merge_name_value_pair_argument(textDefaultOptions,parser.Results.TextOptions);

    corridorDefaultOptions = {'LineWidth',1.5,'Marker','o','Color',color_palette_tol('purple')};
    [~,corridorOptions] = merge_name_value_pair_argument(corridorDefaultOptions,parser.Results.LineOptions,parser.Results.CorridorOptions);

    designSpaceDefaultOptions = {'LineWidth',1.5,'Color','k'};
    [~,designSpaceOptions] = merge_name_value_pair_argument(designSpaceDefaultOptions,parser.Results.LineOptions,parser.Results.DesignSpaceOptions);

    designIntervalsDefaultOptions = {'LineWidth',1.5,'Color',color_palette_tol('cyan')};
    [~,designIntervalsOptions] = merge_name_value_pair_argument(designIntervalsDefaultOptions,parser.Results.LineOptions,parser.Results.DesignIntervalsOptions);

    % if no lower bound is given, take the minimum of the intervals;
    % if only one value is given, assume the same to all intervals
    designSpaceLowerBound = parser.Results.DesignSpaceLowerBound;
    if(isempty(designSpaceLowerBound))
        designSpaceLowerBound = min(designIntervals,[],2);
    end
    if(isscalar(designSpaceLowerBound))
        designSpaceLowerBound = repmat(designSpaceLowerBound,1,size(designIntervals,2));
    end

    % apply same logic to upper bound as lower bound
    designSpaceUpperBound = parser.Results.DesignSpaceUpperBound;
    if(isempty(designSpaceUpperBound))
        designSpaceUpperBound = max(designIntervals,[],2);
    end
    if(isscalar(designSpaceUpperBound))
        designSpaceUpperBound = repmat(designSpaceUpperBound,1,size(designIntervals,2));
    end

    % use x_i labels if none are given
    if(isempty(parser.Results.VariableLabels))
        variableLabels = arrayfun(@(i)sprintf('$x_{%d}$',i),1:size(designIntervals,2),'UniformOutput',false);
    else
        variableLabels = parser.Results.VariableLabels;
    end

    % normalization
    if(parser.Results.NormalizeIntervals)
        designIntervalsPlot = (designIntervals-designSpaceLowerBound)./(designSpaceUpperBound-designSpaceLowerBound);
        designSpaceLowerBoundPlot = zeros(size(designSpaceLowerBound));
        designSpaceUpperBoundPlot = ones(size(designSpaceUpperBound));
    else
        designIntervalsPlot = designIntervals;
        designSpaceLowerBoundPlot = designSpaceLowerBound;
        designSpaceUpperBoundPlot = designSpaceUpperBound;
    end

    activate_graphics_object(graphicsHandle);
    hold on;
    nIntervals = size(designIntervals,2);

    if(parser.Results.PlotCorridor)
        plot(graphicsHandle,...
            1:nIntervals,...
            designIntervalsPlot(1,:),...
            corridorOptions{:});
        plot(graphicsHandle,...
            1:nIntervals,...
            designIntervalsPlot(2,:),...
            corridorOptions{:});
    end
    
    for iInterval = 1:nIntervals
        plot(graphicsHandle,...
            [iInterval iInterval],...
            [designSpaceLowerBoundPlot(iInterval) designSpaceUpperBoundPlot(iInterval)],...
            designSpaceOptions{:});
        plot(graphicsHandle,...
            [iInterval iInterval],...
            [designIntervalsPlot(1,iInterval) designIntervalsPlot(2,iInterval)],...
            designIntervalsOptions{:});
        text(iInterval,designSpaceLowerBoundPlot(iInterval),sprintf(parser.Results.TextFormatting,designSpaceLowerBound(iInterval)),textOptions{:});
        text(iInterval,designSpaceUpperBoundPlot(iInterval),sprintf(parser.Results.TextFormatting,designSpaceUpperBound(iInterval)),textOptions{:});
        text(iInterval,designIntervalsPlot(1,iInterval),sprintf(parser.Results.TextFormatting,designIntervals(1,iInterval)),textOptions{:});
        text(iInterval,designIntervalsPlot(2,iInterval),sprintf(parser.Results.TextFormatting,designIntervals(2,iInterval)),textOptions{:});
    end

    xticks(1:nIntervals);
    if(~isempty(variableLabels))
        set(graphicsHandle,'XTickLabel',variableLabels,labelOptions{:});
    end
    xlim([0.5 nIntervals+0.5]);

    yticks([]);
    set(graphicsHandle,'YColor','none')
end