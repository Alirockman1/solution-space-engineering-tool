% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [O] = Compliance(G, A, O, Mode)

% This function determines the compliance or compliance sensitivities
% Input:  G     : Global data
%         A     : Analysis data
%         O     : Optimization data
%         Mode  : 0: analysis i.e., compute O.Comp
%                 1: SA DSA i.e., compute O.DCompDx using SA DSA
%                 2: Analytical DSA - not yet implemented - your job :-)
% Output:
%   O.Comp or O.DCompDx: Compliance or compliance sensitivities
%
% Revisions:
%   Version 1.0    02.12.2015   Erik Lund

switch Mode
  case 0
    % Analysis: compute compliance
    O.Comp = A.U(:,1)' * A.F(:,1);
    % You may also compute compliance by summation on element level:
    %O.Comp = 0;
    %for ElemNo = 1:G.nElem
    %  [E] = GetFEData(G, ElemNo, 0);
    %  [E] = GetElemU(G, A, E, ElemNo)
    %  ElemKSize = E.nElemDOF^2;
    %  KijOffSet = (ElemNo-1)*ElemKSize;
    %  Ke = reshape(A.Kij(KijOffSet+1:KijOffSet+ElemKSize),[E.nElemDOF E.nElemDOF]);
    %  O.Comp = O.Comp + E.U(:,1)'*Ke*E.U(:,1);
    %end

  case 1
    % SA DSA
    % We use a forward difference approximation of the element
    % stiffness matrix sensitivity
    
    % Initialize compliance sensitivities
    O.DCompDx = zeros(O.nDesVar,1);
    % Loop over all design variables
    for DVNo = 1:O.nDesVar
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
        [E] = GetElemU(G, A, E, 0);
        % Get the unperturbed stiffness matrix Ke stored in A.Kij
        ElemKSize = E.nElemDOF^2;
        KijOffSet = (ElemNo-1)*ElemKSize;
        Ke = reshape(A.Kij(KijOffSet+1:KijOffSet+ElemKSize),[E.nElemDOF E.nElemDOF]);
        % Compute the derivative of the stiffness matrix, DKeDx
        DKeDx = (E.K - Ke) / O.Pert(DVNo);
        % Compute the compliance sensitivity
        O.DCompDx(DVNo) = O.DCompDx(DVNo) - E.U(:,1)'*DKeDx*E.U(:,1);
      end % loop for No
      % Subtracting the perturbation from the model - resetting
      [G] = PerturbDesVar(G, O, DVNo, -1.0);
    end % design variable loop

  case 2
    % Analytical DSA
    disp('Analytical DSA is your task :-)');
  otherwise
    disp('Invalid Mode');
end
