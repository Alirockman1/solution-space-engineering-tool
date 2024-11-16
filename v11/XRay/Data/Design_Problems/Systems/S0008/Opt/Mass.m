% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [O] = Mass(G, O, Mode)

% This function determines the mass or mass sensitivities
% Input:  G     : Global data
%         O     : Optimization data
%         Mode  : 0: analysis i.e., compute O.Mass
%                 1: SA DSA i.e., compute O.DMassDx using SA DSA
%                 2: Analytical DSA - not yet implemented - your job :-)
% Output:
%   O.Mass or O.DMassDx: Mass or mass sensitivities
%
% Revisions:
%   Version 1.0    02.12.2015   Erik Lund

switch Mode
  case 0
    % Analysis: compute mass
    O.Mass = 0;
    % All elements have the same area
    Area = G.ElemLX*G.ElemLY;
    for ElemNo = 1:G.nElem
      PatchNo = G.PatchNo(ElemNo);
      % Loop over the layers
      for k = 1:G.Layup(PatchNo).nLayers
        MatNo = G.Layup(PatchNo).MatNo(k);
        O.Mass = O.Mass + Area*G.Layup(PatchNo).t(k)*G.Mat(MatNo).rho;
      end
    end
    
  case 1
    % SA DSA
    % Compute mass sensitivities using forward difference approximations
    O.DMassDx = zeros(O.nDesVar,1);
    % All elements have the same area
    Area = G.ElemLX*G.ElemLY;

    % Loop over all design variables
    for DVNo = 1:O.nDesVar
      PerturbedMass = 0;
      % Perturb the model for the given design variable - positive direction
      [G] = PerturbDesVar(G, O, DVNo, 1.0);
      % Loop for all elements linked to the design variable
      for No = 1:O.DVInfo(DVNo).nPatchToElemLinks
        ElemNo = O.DVInfo(DVNo).ElemList(No);
        PatchNo = G.PatchNo(ElemNo);
        % Find the layer k that this design variable is linked to
        k = O.LayerNo(DVNo);
        MatNo = G.Layup(PatchNo).MatNo(k);
        PerturbedMass = PerturbedMass + Area*G.Layup(PatchNo).t(k)*G.Mat(MatNo).rho;
        % Subtracting the perturbation from the model - resetting
      end % for 
      [G] = PerturbDesVar(G, O, DVNo, -1.0);
      PerturbedMass = PerturbedMass - Area*G.Layup(PatchNo).t(k)*G.Mat(MatNo).rho;
      % Compute the mass sensitivity using forward difference approximation
      O.DMassDx(DVNo) = PerturbedMass/O.Pert(DVNo);
    end % design variable loop
    
  otherwise
    disp('This DSA mode is not yet implemented')
    stop
end
