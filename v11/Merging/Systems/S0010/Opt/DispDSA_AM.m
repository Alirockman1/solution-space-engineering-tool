% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

% The function performs DSA of displacements using SA AM - Semi-Analytical
% Adjoint Method

function [O] = DispDSA_AM(G, A, O)

% Solve the static analysis problem (assembly + solution)
% Note: we solve the problem using Cholesky factorization in order to
% reuse the factored stiffness matrix

% We loop over all finite elements and assemble the sparse stiffness matrix A.K.
[A] = AssembleK(G, A);
% The stiffness matrix is factored using default matrix decomposition
A.KFactored = decomposition(A.K(A.FreeDOFs,A.FreeDOFs)); 
% The static equilibrium equations are solved
A.U(A.FreeDOFs,:) = A.KFactored \ A.F(A.FreeDOFs,:);
A.U(A.FixedDOFs,:)= 0.0;

% Calculate the criterion function of interest
% We will be interest in the transverse displacement UZ of the lower left 
% node of the model, i.e. NodeNo = G.nNodes.
DOFNo = 5*(G.nNodes-1)+3;

% The criterion function f is extracted from U
f = A.U(DOFNo,1);

% First the adjoint vector V is established
V = zeros(A.nDOFs,1);
V(DOFNo,1) = 1.0;
% Solve the adjoint problem for the vector Gamma using 
% the factored stiffness matrix
Gamma(A.FreeDOFs,:) = A.KFactored \ V(A.FreeDOFs,:);
Gamma(A.FixedDOFs,:)= 0.0;

% Loop over all design variables
%for DVNo = 1:O.nDesVar
  DVNo = 1; % We only perform DSA w.r.t. the first design variable
  % Reset the vector P for every design variable
  P = zeros(A.nDOFs,1);
  % Perturb the model for the given design variable - positive direction
  [G] = PerturbDesVar(G, O, DVNo, 1.0);
  % Loop for all elements linked to the design variable
  for No = 1:O.DVInfo(DVNo).nPatchToElemLinks
    ElemNo = O.DVInfo(DVNo).ElemList(No);
    % Get the element data
    [E] = GetFEData(G, ElemNo, O.DSAMode); 
    % Get the perturbed stiffness matrix E.K
    [E] = ElemK(E);
    % Get the element displacement vector E.U
    [E] = GetElemU(G, A, E, O.DSAMode);
    % Get the unperturbed stiffness matrix Ke stored in A.Kij
    ElemKSize = E.nElemDOF^2;
    KijOffSet = (ElemNo-1)*ElemKSize;
    Ke = reshape(A.Kij(KijOffSet+1:KijOffSet+ElemKSize),[E.nElemDOF E.nElemDOF]);
    % Compute the derivative of the stiffness matrix, DKeDx
    DKeDx = (E.K - Ke) / O.Pert(DVNo);
    % Compute the contribution to P (dR/dx_i)
    P_e = DKeDx*E.U(:,1);
    P(E.DOF) = P(E.DOF) + P_e;
  end % loop for No
  % The displacement sensitivity value of interest is computed
  O.DUzDx_AM(DVNo) = -Gamma'*P;
  
  % Subtracting the perturbation from the model - resetting
  [G] = PerturbDesVar(G, O, DVNo, -1.0);
%end % end of loop over design variables

