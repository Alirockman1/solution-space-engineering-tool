%% Map Variables to Variable Number
function variable_number = get_variable_from_label(dataManager, label)
    % This function searches for the label in dispname and returns the corresponding varno
    variable_number = [];

    % Loop through dispname to find a match
    for i = 1:length({dataManager.Labels.dispname})
        if strcmp(dataManager.Labels(i).dispname, label)
            variable_number = dataManager.Labels(i).varno;
            return;                                                        % Exit once the first match is found
        end
    end
end