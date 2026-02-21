function update_points_per_figure(hFig, dataManager, newValue, event)
    
    % Check if user input is NOT a valid number
    if isnan(newValue)
        uialert(hFig, ...
            "Please enter a valid number.", ...
            "Invalid Input");

        % Reset to previous valid value
        numberOfSamplesPerPlot = event.PreviousValue;
    else
        numberOfSamplesPerPlot = newValue;
    end

    dataManager.update_points_per_figure(numberOfSamplesPerPlot);

end