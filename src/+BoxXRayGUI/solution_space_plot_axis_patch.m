function solution_space_plot_axis_patch(dataManager)
%SOLUTION_SPACE_PLOT_AXIS_PATCH Plot solution space projections with draggable boundaries
%   SOLUTION_SPACE_PLOT_AXIS_PATCH evaluates the design space and plots 2D
%   projections for each desired variable pair. The function generates design
%   samples, evaluates them through the system evaluation function, and plots
%   the results with draggable boundary lines representing solution box bounds.
%   Interactive patches are added to enable dragging of boundary lines.
%
%   SOLUTION_SPACE_PLOT_AXIS_PATCH(DATAMANAGER) evaluates and plots the
%   solution space based on current bounds stored in the data manager.
%
%   Inputs:
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing system evaluation function, design box,
%           design space bounds, QOI limits, plot axes handles, and plotting
%           options
%
%   Outputs:
%       None (plots are created on axes handles stored in dataManager,
%       evaluation data stored in dataManager.PlotData and
%       dataManager.EvaluationData)
%
%   See also evaluate_selective_design_space_projection,
%   plot_design_space_projection_axis, BoxXRayCallback.start_drag_function,
%   BoxXRayCallback.select_data_from_plot.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2025.
%   Copyright 2025 Eduardo Rodrigues Della Noce (Contributor)
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


    %% Get data
    designBox = dataManager.get_design_box;
    designSpace = dataManager.get_design_space;
    designParameters = dataManager.get_design_parameters;
    plotDesiredPairs = dataManager.get_plot_desired_pairs;
    performanceLimits = dataManager.get_quantities_of_interest_limits;
    activeStatus = dataManager.get_quantities_of_interest_active_status;


    %% prepare evaluation function
    systemEvaluation = dataManager.SystemEvaluation;
    if(isa(systemEvaluation,'function_handle'))
        if(nargin(systemEvaluation)==1)
            systemEvaluation = BottomUpMappingFunction(systemEvaluation);
        else
            systemEvaluation = BottomUpMappingFunction(systemEvaluation,designParameters);
        end
    end

    if(isa(systemEvaluation,'BottomUpMappingBase'))
        performanceLowerLimit = performanceLimits(1,:);
        performanceUpperLimit = performanceLimits(2,:);
    else
        performanceLowerLimit = [];
        performanceUpperLimit = [];
    end
    
    % Evaluate solution space engineering
    [plotData,evaluationData] = evaluate_selective_design_space_projection(...
        systemEvaluation, ...
        designBox, ...
        designSpace(1,:), ...
        designSpace(2,:), ...
        plotDesiredPairs, ...
        'NumberSamplesPerPlot', dataManager.NumberOfSamplesPerPlot, ...
        'SamplingMethod', dataManager.SamplingMethod, ...
        'SamplingOptions', dataManager.SamplingOptions, ...
        'MarkerColorsCriterion', dataManager.MarkerColorsCriterion, ...
        'PerformanceMeasureLowerLimit', performanceLowerLimit, ...
        'PerformanceMeasureUpperLimit', performanceUpperLimit,...
        'PerformanceActiveStatus', activeStatus);
    dataManager.PlotData = plotData;
    dataManager.EvaluationData = evaluationData;

    colorArray = dataManager.get_quantities_of_interest_colors_when_violated;
    designVariableDisplayNames = dataManager.get_design_variable_display_names;
    designVariableUnit = dataManager.get_design_variable_units;
    selectDataFromPlotOption = {'ButtonDownFcn', @(src, event) BoxXRayCallback.select_data_from_plot(src, event, dataManager)};

    % Precompute formatted variable labels
    designVariableLabels = cell(numel(designVariableDisplayNames),1);
    for k = 1:numel(designVariableDisplayNames)
        designVariableLabels{k} = makeLabel(designVariableDisplayNames{k}, designVariableUnit{k});
    end

    nPlot = length(plotData);
    for axesIdx = 1:nPlot
        [~,plotOptionsGood] = merge_name_value_pair_argument(dataManager.PlotOptionsGood,selectDataFromPlotOption);
        [~,plotOptionsBad] = merge_name_value_pair_argument(dataManager.PlotOptionsBad,selectDataFromPlotOption);
        [~,plotOptionsPhysicallyInfeasible] = merge_name_value_pair_argument(dataManager.PlotOptionsPhysicallyInfeasible,selectDataFromPlotOption);

        designTypeHandle = plot_design_space_projection_axis(...
            dataManager.PlotAxesHandles(axesIdx), ...
            plotData(axesIdx),...
            'AxesLabels', {designVariableLabels{plotDesiredPairs(axesIdx,1)}, designVariableLabels{plotDesiredPairs(axesIdx,2)}}, ...
            'MarkerColorsViolatedRequirements', colorArray, ...
            'PlotOptionsGood',plotOptionsGood,...
            'PlotOptionsBad',plotOptionsBad,...
            'PlotOptionsPhysicallyInfeasible',plotOptionsPhysicallyInfeasible,...
            'PlotOptionsIntervals',dataManager.PlotOptionsIntervals,...
            'PlotOptionsBox',dataManager.PlotOptionsBox,...
            'AxisLabelsOptions',dataManager.AxisLabelsOptions,...
            'FixPanning',false);

        % merge handles
        if(axesIdx==1)
            legendHandle.GoodPerformance = designTypeHandle.GoodPerformance;
            legendHandle.PhysicallyInfeasible = designTypeHandle.PhysicallyInfeasible;
            legendHandle.BadPerformance = designTypeHandle.BadPerformance;
        else
            if(isa(legendHandle.GoodPerformance,'matlab.graphics.GraphicsPlaceholder') && ...
               ~isa(designTypeHandle.GoodPerformance,'matlab.graphics.GraphicsPlaceholder'))
               legendHandle.GoodPerformance = designTypeHandle.GoodPerformance;
            end
            
            if(isa(legendHandle.PhysicallyInfeasible,'matlab.graphics.GraphicsPlaceholder') && ...
               ~isa(designTypeHandle.PhysicallyInfeasible,'matlab.graphics.GraphicsPlaceholder'))
               legendHandle.PhysicallyInfeasible = designTypeHandle.PhysicallyInfeasible;
            end
            
            for k=1:length(designTypeHandle.BadPerformance)
                if(k>length(legendHandle.BadPerformance) || ...
                    (isa(legendHandle.BadPerformance{k},'matlab.graphics.GraphicsPlaceholder') && ...
                    ~isa(designTypeHandle.BadPerformance{k},'matlab.graphics.GraphicsPlaceholder')))
                    legendHandle.BadPerformance{k} = designTypeHandle.BadPerformance{k};
                end
            end
        end
    end

    % Create dragable boundaries
    nVariable = size(designBox, 2);
    dataManager.DraggabbleVerticalLineHandles = cell(1, nVariable);
    dataManager.DraggabbleVerticalPatchHandles = cell(1, nVariable);
    dataManager.DraggabbleHorizontalLineHandles = cell(1, nVariable);
    dataManager.DraggabbleHorizontalPatchHandles = cell(1, nVariable);
    for plotIdx = 1:nPlot
        plotAxes = dataManager.PlotAxesHandles(plotIdx);
        hold(plotAxes, 'on');
    
        % Extract variable indices
        xVariableIdx = plotDesiredPairs(plotIdx, 1);
        yVariableIdx = plotDesiredPairs(plotIdx, 2);
    
        % Axis limits
        yLimits = ylim(plotAxes);
        xLimits = xlim(plotAxes);
    
        % Values
        xLowerBound = designBox(1,xVariableIdx);
        xUpperBound = designBox(2,xVariableIdx);
        yLowerBound = designBox(1,yVariableIdx);
        yUpperBound = designBox(2,yVariableIdx);
    
        % Vertical lines
        vLineLower = line(plotAxes, [xLowerBound xLowerBound], yLimits, ...
            'Color', dataManager.DraggableLinesColor, ...
            'LineStyle', '--', ...
            'UserData', struct('type', 'left', 'index', xVariableIdx), ...
            'Visible', 'on', ...
            'HandleVisibility', 'on', ...
            'DisplayName', 'Draggable box lines',...
            dataManager.DraggableLineOptions{:});
    
        vLineUpper = line(plotAxes, [xUpperBound xUpperBound], yLimits, ...
            'Color', dataManager.DraggableLinesColor, ...
            'LineStyle', '--', ...
            'UserData', struct('type', 'right', 'index', xVariableIdx), ...
            'Visible', 'on', ...
            'HandleVisibility', 'on',...
            dataManager.DraggableLineOptions{:});
        dataManager.DraggabbleVerticalLineHandles{xVariableIdx} = [dataManager.DraggabbleVerticalLineHandles{xVariableIdx}, [vLineLower;vLineUpper]];

        % Horizontal lines
        hLineLower = line(plotAxes, xLimits, [yLowerBound yLowerBound], ...
            'Color', dataManager.DraggableLinesColor, ...
            'LineStyle', '--', ...
            'UserData', struct('type', 'lower', 'index', yVariableIdx), ...
            'Visible', 'on', ...
            'HandleVisibility', 'on',...
            dataManager.DraggableLineOptions{:});
    
        hLineUpper = line(plotAxes, xLimits, [yUpperBound yUpperBound], ...
            'Color', dataManager.DraggableLinesColor, ...
            'LineStyle', '--', ...
            'UserData', struct('type', 'upper', 'index', yVariableIdx), ...
            'Visible', 'on', 'HandleVisibility', 'on',...
            dataManager.DraggableLineOptions{:});
        dataManager.DraggabbleHorizontalLineHandles{yVariableIdx} = [dataManager.DraggabbleHorizontalLineHandles{yVariableIdx}, [hLineLower;hLineUpper]];
    
        % Remove legend for top/side lines
        vLineUpper.Annotation.LegendInformation.IconDisplayStyle = 'off';
        hLineLower.Annotation.LegendInformation.IconDisplayStyle = 'off';
        hLineUpper.Annotation.LegendInformation.IconDisplayStyle = 'off';
    
        % Add patches for dragging
        vPatchLower = BoxXRayGUI.create_patch_for_line(plotAxes, xLowerBound, 'vertical', 'left', xVariableIdx, vLineLower, dataManager);
        vPatchUpper = BoxXRayGUI.create_patch_for_line(plotAxes, xUpperBound, 'vertical', 'right', xVariableIdx, vLineUpper, dataManager);
        dataManager.DraggabbleVerticalPatchHandles{xVariableIdx} = [dataManager.DraggabbleVerticalPatchHandles{xVariableIdx}, [vPatchLower;vPatchUpper]];
        
        hPatchLower = BoxXRayGUI.create_patch_for_line(plotAxes, yLowerBound, 'horizontal', 'lower', yVariableIdx, hLineLower, dataManager);
        hPatchUpper = BoxXRayGUI.create_patch_for_line(plotAxes, yUpperBound, 'horizontal', 'upper', yVariableIdx, hLineUpper, dataManager);
        dataManager.DraggabbleHorizontalPatchHandles{yVariableIdx} = [dataManager.DraggabbleHorizontalPatchHandles{yVariableIdx}, [hPatchLower;hPatchUpper]];
    
        % Click on empty plot background
        set(plotAxes, 'ButtonDownFcn', @(src, event) BoxXRayCallback.select_data_from_plot(src, event, dataManager));
        hold(plotAxes, 'off');
    end

    violatedText = dataManager.get_quantities_of_interest_violated_text;

    % Wrap long text to fit in legend
    violatedTextFormatted = cell(size(violatedText));
    for i = 1:length(violatedText)
        violatedTextFormatted{i} = wrapTextToLimit(violatedText{i}, 36);
    end

    legendHandleEntries = {legendHandle.GoodPerformance, legendHandle.PhysicallyInfeasible, legendHandle.BadPerformance{:}, vLineLower};
    legendTextEntries = [{'Good Design','Physically Infeasible'}, violatedTextFormatted, {'Draggable box lines'}];
    legendHandle = legend_valid(dataManager.PlotAxesHandles(end), legendHandleEntries, legendTextEntries, 'Location', 'southeast', 'FontSize',7, dataManager.LegendOptions{:});
    uistack(legendHandle, 'top');
end

function label = makeLabel(name, unit)
    if ~isempty(unit)
        label = sprintf('%s [%s]', name, unit);
    else
        label = name;
    end
end

function wrappedText = wrapTextToLimit(inputString, charLimit)
% Wraps a single string into multiple lines (separated by '\n') ensuring no 
% line exceeds charLimit and no word is broken.

    % Split the input string into individual words
    words = strsplit(inputString, ' ');
    if isempty(words) || isempty(inputString)
        wrappedText = inputString;
        return;
    end
    
    % Initialize the first line with the first word
    currentLine = words{1};
    wrappedText = currentLine;
    
    % Iterate over the remaining words
    for i = 2:length(words)
        nextWord = words{i};
        
        % Check if adding the next word (plus a space) exceeds the limit
        % Length of (Current Line + Space + Next Word)
        if length(currentLine) + 1 + length(nextWord) <= charLimit
            % If it fits: append the space and the next word to the current line
            currentLine = [currentLine, ' ', nextWord];
            
            % Update the last part of the overall wrapped string
            % (Replace the previous line with the updated currentLine)
            lastNewLineIndex = find(wrappedText == sprintf('\n'), 1, 'last');
            if isempty(lastNewLineIndex)
                wrappedText = currentLine; % First line
            else
                % Update the line after the last newline character
                wrappedText = [wrappedText(1:lastNewLineIndex), currentLine];
            end
        else
            % If it does NOT fit: start a new line
            wrappedText = [wrappedText, sprintf('\n'), nextWord];
            currentLine = nextWord;
        end
    end
end