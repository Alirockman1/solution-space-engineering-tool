%% Function to update design space based on input
function design_textbox_callback(src, dataManager, varIndex, boundType)
% Callback to update design variable limits from text input

    % Read user input from the text box
    newValue = str2double(src.String);

    % Update the value if it's valid
    if boundType == 1 && newValue <= dataManager.DesignVariables(varIndex).dsub
        dataManager.updateDesignVarBounds(varIndex, boundType, newValue);
    elseif boundType == 2 && newValue >= dataManager.DesignVariables(varIndex).dslb
        dataManager.updateDesignVarBounds(varIndex, boundType, newValue);
    else
        % Reset invalid input to current limits
        if boundType == 1
            set(src, 'String', num2str(dataManager.DesignVariables(varIndex).dslb));
        else
            set(src, 'String', num2str(dataManager.DesignVariables(varIndex).dsub));
        end
        return;
    end

    % Update the slider limit display
    set(dataManager.SliderHandles(varIndex), 'Limits', ...
        [dataManager.DesignVariables(varIndex).dslb, dataManager.DesignVariables(varIndex).dsub]);
end