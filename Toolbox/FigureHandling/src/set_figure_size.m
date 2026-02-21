function set_figure_size(figureHandle,varargin)
    parser = inputParser;
    parser.addOptional('Size',[]);
    parser.addOptional('Position',[]);
    parser.addParameter('Units',[]);
    parser.parse(varargin{:});
    options = parser.Results;

    % set units
    if(isempty(options.Units))
        options.Units = get(figureHandle, 'Units');
    end
    set(figureHandle, 'Units', options.Units);

    % use current position/size if new one wasn't specified
    currentPositionSize = get(figureHandle, 'Position'); % [x from left, y from bottom, width, height]
    if(isempty(options.Position))
        options.Position = currentPositionSize(1:2);
    end
    if(isempty(options.Size))
        options.Size = currentPositionSize(3:4);
    end

    % set position and size
    set(figureHandle, 'Position', [options.Position options.Size]);
end