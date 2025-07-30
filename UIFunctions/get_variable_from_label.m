function variableNumber = get_variable_from_label(dataManager, label)
%GET_VARIABLE_FROM_LABEL Retrieve the variable number associated with a label.
%
%   variable_number = GET_VARIABLE_FROM_LABEL(dataManager, label)
%
%   This utility function searches through the `dataManager.Labels` array to find
%   the `dispname` (display name) that matches the given `label`. Upon finding a match,
%   it returns the corresponding `varno` (variable number) associated with that label.
%
%   INPUTS:
%       dataManager - Structure containing the Labels field, where each element has
%                     a 'dispname' and 'varno' field.
%       label       - A string containing the axis label or display name (e.g., 'x_1').
%
%   OUTPUT:
%       variable_number - The variable number (numeric index) that corresponds to
%                         the matched label. Returns an empty array if no match is found.
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    variableNumber = [];

    % Loop through dispname to find a match
    for i = 1:length({dataManager.Labels.dispname})
        if strcmp([dataManager.DesignVariables(i).dispname...
            ' (' dataManager.DesignVariables(i).unit ')'], label)
            variableNumber = dataManager.Labels(i).varno;
            return;                                                        % Exit once the first match is found
        end
    end
end
