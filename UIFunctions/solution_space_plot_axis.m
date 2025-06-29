function solution_space_plot_axis(dataManager)
% SOLUTION_SPACE_PLOT_AXIS Plots the projected design solution space on specified axes.
%   SOLUTION_SPACE_PLOT_AXIS closes the existing main figure (ID 1), sets up the
%   design variable bounds, evaluates the solution space, and generates subplots
%   visualizing design variable pairs with draggable boundary lines.
%
%   INPUT:
%       dataManager - Struct or class instance containing design variables,
%                     UI handles, plot axes, labels, and evaluation options
%
%   OPERATION:
%       - Closes figure 1 if it exists to refresh the main plotting window
%       - Determines design variable bounds to use, falling back on initial bounds or halved
%         bounds if necessary
%       - Extracts pairs of design variables to plot and their labels
%       - Calls an evaluation function to generate data for plotting the design space
%       - Calls a plotting helper to render the design space on each subplot axis
%       - Adds draggable boundary lines representing variable bounds on each subplot
%       - Sets up callbacks for interaction (dragging boundaries, selecting data points)
%       - Updates legend for design quality indications
%       - Resets any temporary optimum design box
%
%   DEPENDENCIES:
%       - evaluate_selective_design_space_projection: evaluates design space data
%       - plot_design_space_projection_axis: plots individual 2D projections
%       - start_drag_function: callback for draggable boundary lines
%       - select_data_from_plot: callback for selecting data points on plots
%
%   NOTE:
%       - Assumes dataManager contains properly initialized handles and data fields.
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor, Author)
%   Copyright 2025 Ali Abbas Kapadia (Contributor)
%   SPDX-License-Identifier: Apache-2.0

    % Close the already existing figure
    allFigures = findall(0, 'Type', 'figure');
    for i = 1:length(allFigures)
        if allFigures(i) == 1
            close(allFigures(i));                                          % Close the figure
        end
    end

    % desired plots by design variable index
    plotTiles = [1,size(dataManager.DesiredPlots, 2)];                     % 2 rows, 3 columns of subplots

    % Determine the design box to use
    if (~isnan([dataManager.DesignVariables.dinit]))                       % Ensure design initialization is valid
        if isempty(dataManager.OptimumDesignBox)
            dataManager.DesignBox = [[dataManager.DesignVariables.sblb];...
                [dataManager.DesignVariables.sbub]];                       % Use the original design box
        else
            dataManager.DesignBox = dataManager.OptimumDesignBox;          % Use the OptimdesignBox
        end
    else
        dataManager.DesignBox = [[dataManager.DesignVariables.dslb]/2;...
            [dataManager.DesignVariables.dsub]/2];
    end

    for i = 1:size(dataManager.DesiredPlots, 2)
        desiredPlots(i, :) = [dataManager.DesiredPlots(i).axdes{1}, dataManager.DesiredPlots(i).axdes{2}];  % Fill in the rows
        axisLabel{i} = dataManager.Labels(i).dispname;  % Store each name in the cell array 
    end
    
    % Evaluate solution space engineering
    [plotData,evaluationData] = evaluate_selective_design_space_projection(...
        dataManager.DesignEvaluator, ...
        dataManager.DesignBox, ...
        [dataManager.DesignVariables.dslb], ...
        [dataManager.DesignVariables.dsub], ...
        desiredPlots, ...
        'NumberSamplesPerPlot', str2double(dataManager.ExtraOptions.SampleSize));

    dataManager.PlotData = plotData;
    dataManager.EvaluationData = evaluationData;

    for axesIdx = 1:length(plotData)
        designTypeHandle(axesIdx) = plot_design_space_projection_axis(dataManager.PlotData(axesIdx),...
            'DataManager', dataManager,...
            'CurrentAxis', dataManager.AxisHandles.IndividualPlots(axesIdx), ...
            'AxesLabels', desiredPlots(axesIdx,:), ...
            'MarkerColorsViolatedRequirements', 'r', ...
            'PlotOptionsBad', {'Marker', 'x'});
    end

    dataManager.AxisHandles.GoodPerformance = designTypeHandle.GoodPerformance;
    dataManager.AxisHandles.BadPerformance = designTypeHandle.BadPerformance;

    % Reset OptimdesignBox after the solution space has run
    dataManager.OptimumDesignBox = [];

    % Create dragable boundaries
    for i = 1:length(dataManager.AxisHandles.IndividualPlots)

        % Hold on to add draggable lines
        hold(dataManager.AxisHandles.IndividualPlots(i), 'on');

        % Extract variable indices for the current subplot
        xVarIndex = desiredPlots(i, 1); % X variable index
        yVarIndex = desiredPlots(i, 2); % Y variable index

        % Debugging output
        fprintf('Subplot %d: xVarIndex = %d, yVarIndex = %d\n', i, xVarIndex, yVarIndex);
 
        % Create vertical lines for the bounds
        vLineLower = line(dataManager.AxisHandles.IndividualPlots(i),...
            [dataManager.DesignVariables(xVarIndex).sblb;...
            dataManager.DesignVariables(xVarIndex).sblb], ...
            ylim(dataManager.AxisHandles.IndividualPlots(i)),...
            'Color', 'b', 'LineStyle', '--', ...
            'UserData', struct('type', 'left', 'index', xVarIndex), ...
            'Visible', 'on', 'HandleVisibility', 'on');

        vLineUpper = line(dataManager.AxisHandles.IndividualPlots(i),...
            [dataManager.DesignVariables(xVarIndex).sbub;...
            dataManager.DesignVariables(xVarIndex).sbub], ...
            ylim(dataManager.AxisHandles.IndividualPlots(i)),...
            'Color', 'b', 'LineStyle', '--', ...
            'UserData', struct('type', 'right', 'index', xVarIndex), ...
            'Visible', 'on', 'HandleVisibility', 'on');

        % Create horizontal lines for the bounds
        hLineLower = line(dataManager.AxisHandles.IndividualPlots(i),...
            xlim(dataManager.AxisHandles.IndividualPlots(i)), ...
            [dataManager.DesignVariables(yVarIndex).sblb;...
            dataManager.DesignVariables(yVarIndex).sblb], 'Color', 'b', ...
            'LineStyle', '--', 'UserData', struct('type', 'lower', 'index', yVarIndex), ...
            'Visible', 'on', 'HandleVisibility', 'on');

        hLineUpper = line(dataManager.AxisHandles.IndividualPlots(i),...
            xlim(dataManager.AxisHandles.IndividualPlots(i)), ...
            [dataManager.DesignVariables(yVarIndex).sbub;...
            dataManager.DesignVariables(yVarIndex).sbub], 'Color', 'b', ...
            'LineStyle', '--', 'UserData', struct('type', 'upper', 'index', yVarIndex), ...
            'Visible', 'on', 'HandleVisibility', 'on');

        % Set the ButtonDownFcn for dragging
        set([vLineLower, vLineUpper, hLineLower, hLineUpper],...
            'PickableParts', 'all', ...                                    % Ensure it can be picked
            'HitTest', 'on', ...                                           % Ensure it responds to mouse clicks
            'ButtonDownFcn', @(src, event) start_drag_function(src, event, dataManager));

        set(dataManager.AxisHandles.IndividualPlots(i),...
            'ButtonDownFcn', @(src, event) select_data_from_plot(src,...
            event, i, dataManager, textAreas));

        hold(dataManager.AxisHandles.IndividualPlots(i), 'off');
    end

    legend([dataManager.AxisHandles.GoodPerformance,...
        dataManager.AxisHandles.BadPerformance],...
        {'Good Designs','Violate Distance Requirement'});
end