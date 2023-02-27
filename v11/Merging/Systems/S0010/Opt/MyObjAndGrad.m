% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

% The function MyObjAndGrad returns the objective function f and its gradients
% using analytical or semi-analytical (SA) DSA

function [f, c] = MyObjAndGrad(x, G, A, O)

  % This function updates the model based on the design variables
  % of the model and copies x to O.x. 
  [G] = UpdateModel(G, O, x);

  % Solve the static analysis problem
  [A] = SolveStatic(G,A);
  
  % Calculate compliance 
  [O] = Compliance(G, A, O, 0);

  % The current function value of f is set to the compliance value
  f = O.Comp;
  
  % If the function is called with more than one argument, then gradients
  % will be computed and returned in the gradient vector c:
  if (nargout > 1)
    % DSA is only performed once per iteration, thus we display the current result:
    disp([' Obj.: ' sprintf('%10.4f',f)]);
    % Calculate compliance sensitivities
    [O] = Compliance(G, A, O, O.DSAMode);  
    c = O.DCompDx;
  end 
end
