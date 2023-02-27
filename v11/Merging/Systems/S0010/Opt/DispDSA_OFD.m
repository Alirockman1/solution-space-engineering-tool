% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

% The function performs DSA using OFD - Overall Finite Difference
% approximations, here forward difference approximations

function [O] = DispDSA_OFD(G, A, O)

% Solve the static analysis problem (assembly + solution)
[A] = SolveStatic(G,A);
  
% Calculate the criterion function of interest
% We will be interest in the transverse displacement UZ of the lower left 
% node of the model, i.e. NodeNo = G.nNodes.
DOFNo = 5*(G.nNodes-1)+3;
% The original displacements are stored in U
U = A.U;

% The criterion function f is extracted from U
f = U(DOFNo,1);
  
% Calculate displacement sensitivities using OFD
% Loop over all design variables
%for DVNo = 1:O.nDesVar
  DVNo = 1; % We only perform DSA w.r.t. the first design variable
  % Perturb the model for the given design variable - positive direction
  [G] = PerturbDesVar(G, O, DVNo, 1.0);
  % Solve the static analysis problem (assembly + solution)
  [A] = SolveStatic(G,A);
  % Compute the displacement sensitivities - we compute the whole field,
  % even though we only need the value at one DOF. It is stored as
  % O.DUDx_OFD such that we can plot it later
  O.DUDx_OFD = (A.U-U)/O.Pert(DVNo);
  O.DUzDx_OFD(DVNo) = O.DUDx_OFD(DOFNo);  % (A.U(DOFNo,1)-f)/O.Pert(DVNo);
  % Subtracting the perturbation from the model - resetting
  [G] = PerturbDesVar(G, O, DVNo, -1.0);
%end % end of loop over design variables

