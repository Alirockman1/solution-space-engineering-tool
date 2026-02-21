function legendObject = legend_valid(axisHandle,handleObject,legendText,varargin)
    % Filter out empty, placeholder, or invalid/non-graphics handles
    isValidFunction = @(x) ...
        ~isempty(x) && ...
        ~isa(x,'matlab.graphics.GraphicsPlaceholder') && ...
        isgraphics(x) && ...
        isvalid(x);
    isValid = cellfun(isValidFunction, handleObject);

    handleObjectValid = [handleObject{isValid}];
    legendTextValid = {legendText{isValid}};

    % process
    hasOutput = (nargout>0);
    if(~isempty(handleObjectValid))
        if(hasOutput)
            legendObject = legend(axisHandle, handleObjectValid, legendTextValid, varargin{:});
        else
            legend(axisHandle, handleObjectValid, legendTextValid, varargin{:});
        end
    else
        if(hasOutput)
            legendObject = legend(axisHandle,'off');
        else
            legend(axisHandle,'off');
        end
    end
end