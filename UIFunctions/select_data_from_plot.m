function select_data_from_plot(src, event, dataManager)
%SELECT_DATA_FROM_PLOT Callback to handle user interaction with plot points.
%
%   This function is triggered when the user clicks on a point within a 2D
%   design space projection plot. If selection mode is active in the 
%   DataManager, the function identifies which design sample was clicked 
%   by calculating the closest match in the 2D projected space.
%
%   INPUTS:
%       src         - The graphical object that was clicked (typically a plotted marker).
%       event       - Event data containing the click position and intersection point.
%       dataManager - An instance of the DataManager object holding plot handles,
%                     design samples, and UI text field handles.
%
%   FUNCTIONALITY:
%       - Identifies the clicked subplot and corresponding design variables.
%       - Matches the click location to the closest actual sample in the 2D plot.
%       - Updates UI text fields with the selected design variable values and
%         their corresponding quantity of interest (QoI) or performance metric.
%       - Disables selection mode after the selection is completed.
%
%   NOTE:
%       The function relies on axis labels to decode variable indices (e.g., 'x_3' → 3)
%       and assumes that `dataManager.AxisHandles.IndividualPlots`, 
%       `EvaluationData`, and `DataTextHandles` are appropriately initialized.
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    % Make sure button for point selection was activated
    if isempty(dataManager.SelectionModeActive) || ~dataManager.SelectionModeActive
        return; % Ignore click if not in selection mode
    end

    % Get Axes
    axes = ancestor(src, 'axes');

    % Find index 'i' of the clicked axes in the list
    idx = find(dataManager.AxisHandles.IndividualPlots == axes, 1);

    % Get click coordinates
    clickPoint = event.IntersectionPoint;
    xClick = clickPoint(1);
    yClick = clickPoint(2);

    ax = dataManager.AxisHandles.IndividualPlots(idx);
    xLabel = ax.XLabel.String; % Get the x-axis label
    yLabel = ax.YLabel.String; % Get the y-axis label

    % Retrieve variable numbers based on labels
    xVarNo = str2num(get_variable_from_label(dataManager, xLabel));
    yVarNo = str2num(get_variable_from_label(dataManager, yLabel));

    if isempty(xVarNo) || isempty(yVarNo)
        disp('Error: One or both variable numbers could not be found.');
        dataManager.SelectionModeActive = false;
        return;
    end

    % Extract the design samples for the current plot
    designSamples = dataManager.EvaluationData.DesignSample;
    QOI = dataManager.EvaluationData.EvaluatorOutput.PerformanceMeasure;
    feasibility = dataManager.EvaluationData.EvaluatorOutput.PhysicalFeasibilityMeasure;

    % Get the selected design variable values
    selectedVars = [xClick, yClick];
    
    % Get the column indices of selected variables
    selectedCols = [xVarNo, yVarNo];

    % Calculate Euclidean distances in that 2D projection
    distances = sqrt(sum((designSamples(:, selectedCols) - selectedVars).^2, 2));

    % Find the index of the closest point
    [~, closestIndex] = min(distances);
    closestPoint = designSamples(closestIndex, :);
    closestqoi   = QOI(closestIndex);

    % Update the text areas with the selected values
    for i = 1:length({dataManager.Labels.dispname})
        dataManager.DataTextHandles(i).String = num2str(closestPoint(i), '%.4f');
    end

    for j = 1:length(closestqoi)
        dataManager.DataTextHandles(i+j).String = num2str(closestqoi, '%.4f');
    end

    dataManager.SelectionModeActive = false;
end