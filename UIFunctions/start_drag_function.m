%% Function to drag the boundaries
function start_drag_function(~, ~, dataManager)
    % Get the figure and current axes
    fig = gcf;
    if fig.Number ~= 1                                                     % Check if the current figure is not Figure 1
        return;                                                            % Exit the function if it's not Figure 1
    end

    currentAxes = gca;                                                     % Current axes

    % Set the WindowButtonMotionFcn to track movement
    set(fig, 'WindowButtonMotionFcn', @draggingFcn);
    set(fig, 'WindowButtonUpFcn', @stopDragFcn);

    % Store the current line handle
    lineHandle = gco;                                                      % Get the current object (the line)
    
    if ~strcmp(get(lineHandle, 'Type'), 'line')
        return;                                                            % Exit if it's not a line
    end

    function draggingFcn(~, ~)
        % Get the current mouse position
        mousePos = get(currentAxes, 'CurrentPoint');
        xPos = mousePos(1, 1);                                             % X coordinate of the mouse
        yPos = mousePos(1, 2);                                             % Y coordinate of the mouse

        % Check which line is being dragged
        userData = get(lineHandle, 'UserData');
        switch userData.type
            case {'lower', 'upper'}
                % Update horizontal line (Y position)
                set(lineHandle, 'YData', [yPos yPos]);
            case {'left', 'right'}
                % Update vertical line (X position)
                set(lineHandle, 'XData', [xPos xPos]);
        end
    end

    function stopDragFcn(~, ~)
        % Get the current figure and axes
        fig = gcf;
        if fig.Number ~= 1
            return;                                                        % Exit if it's not Figure 1
        end

        % Reset the motion and up functions
        set(fig, 'WindowButtonMotionFcn', '');
        set(fig, 'WindowButtonUpFcn', '');

        % Update the bounds based on the current position of the lines
        userData = get(lineHandle, 'UserData');
        index = userData.index;                                            % Get the index of the variable

        switch userData.type
            case 'lower'
                newValue = get(lineHandle, 'YData');
                dataManager.DesignVariables(index).sblb = newValue(1);     % Update lower bound for variable index
                set(dataManager.TextHandles(index, 1), 'String',...
                    num2str(dataManager.DesignVariables(index).sblb, '%.2f')); % Update text box
                set(dataManager.SliderHandles(index), 'Value',...
                    [dataManager.DesignVariables(index).sblb ...
                    dataManager.DesignVariables(index).sbub]);             % Update Slider
 
            case 'upper'
                newValue = get(lineHandle, 'YData');
                dataManager.DesignVariables(index).sbub = newValue(1);     % Update upper bound
                set(dataManager.TextHandles(index, 2), 'String',...
                    num2str(dataManager.DesignVariables(index).sbub, '%.2f')); % Update text box
                set(dataManager.SliderHandles(index), 'Value',...
                    [dataManager.DesignVariables(index).sblb ...
                    dataManager.DesignVariables(index).sbub]);             % Update Slider

            case 'left'
                newValue = get(lineHandle, 'XData');
                dataManager.DesignVariables(index).sblb = newValue(1);     % Update lower bound
                set(dataManager.TextHandles(index, 1), 'String',...
                    num2str(dataManager.DesignVariables(index).sblb, '%.2f')); % Update text box
                set(dataManager.SliderHandles(index), 'Value',...
                    [dataManager.DesignVariables(index).sblb ...
                    dataManager.DesignVariables(index).sbub]);             % Update Slider

            case 'right'
                newValue = get(lineHandle, 'XData');
                dataManager.DesignVariables(index).sbub = newValue(1);     % Update upper bound
                set(dataManager.TextHandles(index, 2), 'String',...
                    num2str(dataManager.DesignVariables(index).sbub, '%.2f')); % Update text box
                set(dataManager.SliderHandles(index), 'Value',...
                    [dataManager.DesignVariables(index).sblb ...
                    dataManager.DesignVariables(index).sbub]);             % Update Slider
        end

        updateDesignVariableLines(index, dataManager)
    end
end