%% Function to update the desired solution box in all figures
function updateDesignVariableLines(index, dataManager)

    for i = 1:length(dataManager.PlotHandles.IndividualPlots)
        % Get current axes
        ax = dataManager.PlotHandles.IndividualPlots(i);
        
        % Find all line objects in the current axes
        allLines = findobj(ax, 'Type', 'line');
        
        % Initialize empty arrays for vertical and horizontal lines
        vLines = [];
        hLines = [];
        
        % Separate vertical and horizontal lines based on UserData
        for j = 1:length(allLines)
            ud = get(allLines(j), 'UserData');
            if isfield(ud, 'type') && isfield(ud, 'index')
                if ismember(ud.type, {'left', 'right'})
                    vLines = [vLines; allLines(j)];
                elseif ismember(ud.type, {'lower', 'upper'})
                    hLines = [hLines; allLines(j)];
                end
            end
        end
        
        % Update the vertical lines for the given index
        for j = 1:length(vLines)
            ud = get(vLines(j), 'UserData');
            if ud.index == index
                switch ud.type
                    case 'left'
                        % Update the line position based on the new value
                        newValue = dataManager.DesignVariables(index).sblb; % Assuming you want to update based on lower bound
                    case 'right'
                        % Update the line position based on the new value
                        newValue = dataManager.DesignVariables(index).sbub; % Assuming you want to update based on upper bound
                end
                set(vLines(j), 'XData', [newValue newValue]);
            end
        end
        
        % Update the horizontal lines for the given index
        for j = 1:length(hLines)
            ud = get(hLines(j), 'UserData');
            if ud.index == index
                switch ud.type
                    case 'lower'
                        % Update the line position based on the new value
                        newValue = dataManager.DesignVariables(index).sblb; % Assuming you want to update based on lower bound
                    case 'upper'
                        % Update the line position based on the new value
                        newValue = dataManager.DesignVariables(index).sbub; % Assuming you want to update based on upper bound
                end
                % Update the line position based on the new value
                set(hLines(j), 'YData', [newValue newValue]);
            end
        end
    end
end