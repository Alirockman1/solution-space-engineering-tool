% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

% The function MyObjAndGrad returns the objective function f and its gradients.
% Gradients are computed using OFD - Overall Finite Difference
% approximations, here forward difference approximations

function [f, c] = MyObjAndGrad_OFD(x, G, A, O)

  % This function updates the model based on the design variables
  % of the model and copies x to O.x. 
  [G] = UpdateModel(G, O, x);

  % Solve the static analysis problem (assembly + solution)
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
    % Calculate compliance sensitivities using OFD
    % Loop over all design variables
    for DVNo = 1:O.nDesVar
      % Perturb the model for the given design variable - positive direction
      [G] = PerturbDesVar(G, O, DVNo, 1.0);
      % Solve the static analysis problem (assembly + solution)
      [A] = SolveStatic(G,A);
      % Calculate compliance 
      [O] = Compliance(G, A, O, 0);
      O.DCompDx(DVNo) =  (O.Comp - f)/O.Pert(DVNo);
      % Subtracting the perturbation from the model - resetting
      [G] = PerturbDesVar(G, O, DVNo, -1.0);
    end
    c = O.DCompDx;
  end 
end
