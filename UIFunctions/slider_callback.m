%% Function to update text and boundaries based on slider
function slider_callback(dataManager, varIndex)
% SLIDER_CALLBACK Updates design variable bounds and textboxes from slider input.
%
%   SLIDER_CALLBACK(DATAMANAGER, VARINDEX) is a GUI callback function triggered 
%   when a user adjusts the slider corresponding to a design variable. It reads 
%   the slider values, updates the internal design bounds in the dataManager, 
%   synchronizes the related text boxes, and refreshes the plot visuals.
%
%   INPUT:
%       dataManager - Struct or class instance containing:
%           - DesignVariables: array of structs with design variable info:
%               - sblb: slider bound lower value
%               - sbub: slider bound upper value
%           - SliderHandles: array of slider UI handles
%           - TextHandles.DesignBox: text input handles for bounds
%       varIndex    - Index of the design variable being updated
%
%   FUNCTIONALITY:
%       - Verifies the slider handle is valid
%       - Reads slider values (lower and upper bounds)
%       - Rounds slider values to two decimal places and updates design bounds 
%         via dataManager.updateDesignBounds
%       - Updates associated text boxes to reflect new slider values
%       - Calls updateDesignVariableLines to refresh the visualization
%
%   OUTPUT:
%       None (operates via GUI handles and modifies dataManager in-place)
%
%   DEPENDENCIES:
%       - dataManager.updateDesignBounds
%       - updateDesignVariableLines
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    if ishandle(dataManager.SliderHandles(varIndex))
        infoMatrix = get(dataManager.SliderHandles(varIndex), 'Value');

        % Update data in dataManager
        dataManager.updateDesignBounds(varIndex, 1, round(infoMatrix(1,1),2)); % Lower bound
        dataManager.updateDesignBounds(varIndex, 2, round(infoMatrix(1,2),2)); % Upper bound

        % Update text boxes
        set(dataManager.TextHandles.DesignBox(varIndex, 1), 'String',...
            num2str(dataManager.DesignVariables(varIndex).sblb));
        set(dataManager.TextHandles.DesignBox(varIndex, 2), 'String',...
            num2str(dataManager.DesignVariables(varIndex).sbub));

    else
        disp('Invalid slider handle');
    end
  
    % Update Plot boundaries
    updateDesignVariableLines(varIndex, dataManager)
end