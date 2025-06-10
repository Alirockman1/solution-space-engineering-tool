%% Function to update sliders based on text input
function textbox_callback(dataManager, varIndex, boundType)
% Function to retrieve data from the slider.
% The slider Position are updated 
% The values are checked against the max and min 
% The bounds in solution shape plots are updated [TO BE ADDED]

    newValue = str2double(get(dataManager.TextHandles(varIndex, boundType), 'String'));

    % Validate and update the value
    if boundType == 1 && newValue >= dataManager.DesignVariables(varIndex).dslb % Lower bound
        dataManager.updateDesignVarBounds(varIndex, boundType, newValue);
        set(dataManager.SliderHandles(varIndex), 'Value', ...
            [dataManager.DesignVariables(varIndex).sblb, dataManager.DesignVariables(varIndex).sbub]);

    elseif boundType == 2 && newValue <= dataManager.DesignVariables(varIndex).dsub % Upper bound
        dataManager.updateDesignVarBounds(varIndex, boundType, newValue);
        set(dataManager.SliderHandles(varIndex), 'Value', ...
            [dataManager.DesignVariables(varIndex).sblb, dataManager.DesignVariables(varIndex).sbub]);

    else
        % Reset to previously defined limit if invalid
        if boundType == 1
            set(dataManager.TextHandles(varIndex, 1), 'String',...
                num2str(dataManager.DesignVariables(varIndex).dslb));
            set(dataManager.SliderHandles(varIndex), 'Value',...
                [dataManager.DesignVariables(varIndex).dslb,...
                dataManager.DesignVariables(varIndex).sbub]);
        elseif boundType == 2
            set(dataManager.TextHandles(varIndex, 2), 'String',...
                num2str(dataManager.DesignVariables(varIndex).dsub));
            set(dataManager.SliderHandles(varIndex), 'Value',...
                [dataManager.DesignVariables(varIndex).sblb,...
                dataManager.DesignVariables(varIndex).dsub]);
        end
    end

    % Update plot visuals after bounds change
    updateDesignVariableLines(varIndex, dataManager.DesignVariables);
end