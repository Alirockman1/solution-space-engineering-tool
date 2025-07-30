function solution_space_plot_axis_patch(dataManager)
% SOLUTION_SPACE_PLOT_AXIS Plots the projected design solution space on specified axes.
%   SOLUTION_SPACE_PLOT_AXIS closes the existing main figure (ID 1), sets up the
%   design variable bounds, evaluates the solution space, and generates subplots
%   visualizing design variable pairs with draggable boundary lines.
%s
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
    for plotIdx = 1:length(allFigures)
        if allFigures(plotIdx) == 1
            close(allFigures(plotIdx));                                          % Close the figure
        end
    end

    % Determine the design box to use
    if isempty(dataManager.OptimumDesignBox)
        dataManager.DesignBox = [[dataManager.DesignVariables.sblb];...
            [dataManager.DesignVariables.sbub]];                       % Use the original design box
    else
        dataManager.DesignBox = dataManager.OptimumDesignBox;          % Use the OptimdesignBox
    end

    for plotIdx = 1:numel(dataManager.DesiredPlots)
        desiredPlots(plotIdx, :) = [str2double(dataManager.DesiredPlots(plotIdx).axdes{1}),
            str2double(dataManager.DesiredPlots(plotIdx).axdes{2})];  % Fill in the rows 
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

    colorArray = arrayfun(@(q) q.color, dataManager.QuantatiesOfInterests, 'UniformOutput', false);

    for axesIdx = 1:length(plotData)
        designTypeHandle(axesIdx) = plot_design_space_projection_axis(dataManager,...
            axesIdx, ...
            'DataManager', dataManager,...
            'CurrentAxis', dataManager.AxisHandles.IndividualPlots(axesIdx), ...
            'AxesLabels', desiredPlots(axesIdx,:), ...
            'MarkerColorsViolatedRequirements', colorArray, ...
            'PlotOptionsBad', {'Marker', 'x'});
    end

    dataManager.AxisHandles.GoodPerformance = designTypeHandle.GoodPerformance;
    dataManager.AxisHandles.BadPerformance = designTypeHandle.BadPerformance;

    % Reset OptimdesignBox after the solution space has run
    dataManager.OptimumDesignBox = [];

    % Create dragable boundaries
    for plotIdx = 1:length(dataManager.AxisHandles.IndividualPlots)
    
        plotAxes = dataManager.AxisHandles.IndividualPlots(plotIdx);
        hold(plotAxes, 'on');
    
        % Extract variable indices
        xVariableIdx = desiredPlots(plotIdx, 1);
        yVariableIdx = desiredPlots(plotIdx, 2);
    
        fprintf('Subplot %d: xVarIndex = %d, yVarIndex = %d\n', plotIdx, xVariableIdx, yVariableIdx);
    
        % Axis limits
        ylims = ylim(plotAxes);
        xlims = xlim(plotAxes);
    
        % Values
        xLowerBound = dataManager.DesignVariables(xVariableIdx).sblb;
        xUpperBound = dataManager.DesignVariables(xVariableIdx).sbub;
        yLowerBound = dataManager.DesignVariables(yVariableIdx).sblb;
        yUpperBound = dataManager.DesignVariables(yVariableIdx).sbub;
    
        % Vertical lines
        vLineLower = line(plotAxes, [xLowerBound xLowerBound], ylims, ...
            'Color', 'b', 'LineStyle', '--', ...
            'UserData', struct('type', 'left', 'index', xVariableIdx), ...
            'Visible', 'on', 'HandleVisibility', 'on', ...
            'DisplayName', 'Draggable box lines');
    
        vLineUpper = line(plotAxes, [xUpperBound xUpperBound], ylims, ...
            'Color', 'b', 'LineStyle', '--', ...
            'UserData', struct('type', 'right', 'index', xVariableIdx), ...
            'Visible', 'on', 'HandleVisibility', 'on');
    
        % Horizontal lines
        hLineLower = line(plotAxes, xlims, [yLowerBound yLowerBound], ...
            'Color', 'b', 'LineStyle', '--', ...
            'UserData', struct('type', 'lower', 'index', yVariableIdx), ...
            'Visible', 'on', 'HandleVisibility', 'on');
    
        hLineUpper = line(plotAxes, xlims, [yUpperBound yUpperBound], ...
            'Color', 'b', 'LineStyle', '--', ...
            'UserData', struct('type', 'upper', 'index', yVariableIdx), ...
            'Visible', 'on', 'HandleVisibility', 'on');
    
        % Remove legend for top/side lines
        vLineUpper.Annotation.LegendInformation.IconDisplayStyle = 'off';
        hLineLower.Annotation.LegendInformation.IconDisplayStyle = 'off';
        hLineUpper.Annotation.LegendInformation.IconDisplayStyle = 'off';
    
        % Add patches for dragging
        create_patch_for_line(plotAxes, xLowerBound, ylims, 'vertical', 'left', xVariableIdx, dataManager,vLineLower);
        create_patch_for_line(plotAxes, xUpperBound, ylims, 'vertical', 'right', xVariableIdx, dataManager,vLineUpper);
        create_patch_for_line(plotAxes, xlims, yLowerBound, 'horizontal', 'lower', yVariableIdx, dataManager,hLineLower);
        create_patch_for_line(plotAxes, xlims, yUpperBound, 'horizontal', 'upper', yVariableIdx, dataManager,hLineUpper);
    
        % Click on empty plot background
        set(plotAxes, 'ButtonDownFcn', @(src, event) select_data_from_plot(src, event, dataManager));
    
        hold(plotAxes, 'off');
    end
    
    legend(dataManager.AxisHandles.IndividualPlots(1),'show', 'Location', 'best');

end