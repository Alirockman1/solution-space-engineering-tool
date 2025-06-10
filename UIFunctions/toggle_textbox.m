%% Callback function to toggle text box enable state
function toggle_textbox(chk, dataManager, qoiIndex)
    % Toggle the QOI status using class method
    
    if isgraphics(chk) && ishandle(chk) && strcmp(chk.Type, 'uicontrol')
        dataManager.toggleQOIStatus(qoiIndex);
    end
end