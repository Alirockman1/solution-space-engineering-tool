%% Function to Select Data from the Plot and Display
function select_data_from_plot(dataManager,textAreas)
    % Make figure 2 the current figure
    figure(1);

    % Get the selected point from the plot
    [xClick, yClick] = ginput(1); % Wait for the user to click on the plot

    currentAxes = gca; % Current axes
    selectedPlotTag = get(currentAxes, 'Tag'); % Retrieve the tag

    for i = 1:length(dataManager.PlotHandles.IndividualPlots)
        plotTag = sprintf('Plot%d', i);

        if strcmp(plotTag, selectedPlotTag) % Use strcmp for string comparison
            ax = dataManager.PlotHandles.IndividualPlots(i);
            xLabel = ax.XLabel.String; % Get the x-axis label
            yLabel = ax.YLabel.String; % Get the y-axis label

            % Retrieve variable numbers based on labels
            xVarNo = str2num(get_variable_from_label(dataManager, xLabel));
            yVarNo = str2num(get_variable_from_label(dataManager, yLabel));

            if isempty(xVarNo) || isempty(yVarNo)
                disp('Error: One or both variable numbers could not be found.');
                return;
            end

            % Extract the design samples for the current plot
            designSamples = dataManager.PlotData(i).DesignSample;
            QOI = dataManager.PlotData(i).EvaluatorOutput.PerformanceMeasure;
            feasibility = dataManager.PlotData(i).EvaluatorOutput.PhysicalFeasibilityMeasure;

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
    for i = 1:length({dataManager.Labels.dispname})
        textAreas(i).String = num2str(closestPoint(i), '%.4f');
    end

    for j = 1:length(closestqoi)
    textAreas(i+j).String = num2str(closestqoi, '%.4f');
    end
end