%% samplePointCreation
% 
% Creates sample points according to chosen options
%
% *INPUT*
%
% * |obj|           OBJECT of problem defining class
% * |h|             Index of related diagram
% * |X|             Already existing sample points (optional)
% * |Y|             Already existing evaluations (optional)
% * |options|       More options (optional)
% 
% *OUTPUT*
%
% * |x|             Suggested sample points for given diagram
%
% *Example Use*
%
% * x = samplePointCreation(obj, h) creates sample points for given 
% diagram h
% * x = samplePointCreation(___, type='rand') creates random sampling
%
% *Use of X and Y not yet implemented*


function x = samplePointCreation(obj, h, X, Y, options)
arguments
    obj
    h
    X = 0
    Y = 0
    options.type = 'rand'
end


switch options.type

    case 'rand'
        x0=obj.diagram(h,:);

        x = zeros(obj.d, obj.sampleSize);

        for i=1:obj.d
            if any(i==x0)
                x(i,:) = obj.x(i).dsl + (-obj.x(i).dsl + obj.x(i).dsu) * rand(1,obj.sampleSize);
            else
                x(i,:) = obj.x(i).l + (-obj.x(i).l + obj.x(i).u) * rand(1,obj.sampleSize);
            end
        end

    otherwise
        error('No correct type given')
end

end

