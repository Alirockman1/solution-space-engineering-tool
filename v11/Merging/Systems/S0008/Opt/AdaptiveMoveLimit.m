% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [xLower, xUpper] = AdapMoveLimit(x, nDesVar, MoveLimit, k, xL, xU, ...
                   xLower, xUpper,xIterMinusOne, xIterMinusTwo, Reduction)

% Function for adaptive move limit strategy where we for the current 
% linearization around the design point x determine:
% - xLower(i): Lower bound for x(i)
% - uUpper(i): Upper bound for x(i)
% Input:
% x: Design variables
% k: Iteration number
% xL: Lower bounds on x
% xU: Upper bounds on x
% xLower: current lower bound on x
% xUpper: current upper bound on x
% xIterMinusOne: Design variables from last iteration
% xIterMinusTwo: Design variables from second last iteration
% Reduction: Reduction factor used in the adaptive move limit scheme

  if (k > 1)
    for i =1:nDesVar
      delta = (xUpper(i)-xLower(i))/2; % This was the previous allowable change
      % Use the iteration history to determine whether we have oscillations
      % in the design variables
      if (abs(x(i)-xIterMinusOne(i)) > 1.e-10)
        s1 = (xIterMinusOne(i)-xIterMinusTwo(i)) / (x(i)-xIterMinusOne(i));
        if (s1 < 0.0)
          delta = delta*Reduction^2;      % Reduce twice in case of oscillation
        else
          delta = delta/Reduction;        % Relax once if stable
        end
      end
      dmax = (xU(i)-xL(i))*MoveLimit;
      if (delta > dmax) 
        delta = dmax;
      end
      % Initial extimate of lower and upper bound on x(i)
      xLower(i) = x(i) - delta;
      xUpper(i) = x(i) + delta;
      % Make sure we are within the feasible domain
      xLower(i) = max(xLower(i),xL(i));
      xUpper(i) = min(xUpper(i),xU(i));
      % Take care of extremely small design changes where the bounds may be interchanged 
      if (xLower(i) >= xUpper(i)); xLower(i) = 0.9999999*xUpper(i); end;
      if (xUpper(i) <= xLower(i)); xUpper(i) = 1.0000001*xLower(i); end;
    end
  else
    for i =1:nDesVar
      delta = (xU(i)-xL(i))*MoveLimit/2;   % Start out slowly by using MoveLimit/2
      % Initial extimate of lower and upper bound on x(i)
      xLower(i) = x(i) - delta;
      xUpper(i) = x(i) + delta;
      % Make sure we are within the feasible domain
      xLower(i) = max(xLower(i),xL(i));
      xUpper(i) = min(xUpper(i),xU(i));
    end
  end

end

