%% Function to update text and boundaries based on slider
function slider_callback(dataManager, varIndex)
% Function to retrieve data from the slider.
% The text boxes are updated 
% The bounds in solution shape plots are updated [TO BE ADDED]

    if ishandle(dataManager.SliderHandles(varIndex))
        infoMatrix = get(dataManager.SliderHandles(varIndex), 'Value');

        % Update data in dataManager
        dataManager.updateDesignVarBounds(varIndex, 1, round(infoMatrix(1,1),2)); % Lower bound
        dataManager.updateDesignVarBounds(varIndex, 2, round(infoMatrix(1,2),2)); % Upper bound

        % Update text boxes
        set(dataManager.TextHandles(varIndex, 1), 'String',...
            num2str(dataManager.DesignVariables(varIndex).sblb));
        set(dataManager.TextHandles(varIndex, 2), 'String',...
            num2str(dataManager.DesignVariables(varIndex).sbub));

    else
        disp('Invalid slider handle');
    end
  
    % Update Plot boundaries
    updateDesignVariableLines(varIndex, dataManager)
end