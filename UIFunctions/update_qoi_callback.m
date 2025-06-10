%% Function to update the QOI
function update_qoi_callback(dataManager, nQOI)
    % Update QOI limits based on textbox input using class method
    for qoiIndex = 1:nQOI
        if strcmp(dataManager.QOIs(qoiIndex).status, 'active')
            % Get new QOI limits from text fields
            lowerVal = str2double(get(dataManager.QOITextHandles(qoiIndex, 1), 'String'));
            upperVal = str2double(get(dataManager.QOITextHandles(qoiIndex, 2), 'String'));
            
            dataManager.updateQOIBounds(qoiIndex, 1, lowerVal);            % Lower bound
            dataManager.updateQOIBounds(qoiIndex, 2, upperVal);            % Upper bound
        else
            % Inactive: set bounds to unbounded values
            dataManager.updateQOIBounds(qoiIndex, 1, -inf);
            dataManager.updateQOIBounds(qoiIndex, 2, inf);
        end
    end
end