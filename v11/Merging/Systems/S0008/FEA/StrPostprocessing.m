% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [A] = StrPostprocessing(G, A)
% This function performs postprocessing and computes element strains, 
% stresses and failure indices
%
% Input:  G : Global data
%         A : Analysis data
% Output: A : A.StrainXY, A.StressXY, A.Strain12, A.Stress12,
%             A.SE, A.SED, A.FIdx, and A.FIdxMode

% Initialize global matrices with strains, stresses, strain energy, 
% strain energy density, and failure indices
A.StrainXY = zeros(6,G.nElem,G.Layup(1).nLayers,2);   % Strains in X-Y
A.StressXY = zeros(6,G.nElem,G.Layup(1).nLayers,2);   % Stresses in X-Y
A.Strain12 = zeros(6,G.nElem,G.Layup(1).nLayers,2);   % Strains in 1-2
A.Stress12 = zeros(6,G.nElem, G.Layup(1).nLayers,2);  % Stresses in 1-2
A.SE = zeros(G.nElem, G.Layup(1).nLayers);            % Strain energy
A.SED = zeros(G.nElem, G.Layup(1).nLayers);           % Strain energy density
A.FIdx = zeros(3, G.nElem, G.Layup(1).nLayers,2);     % Failure index
A.FIdxMode = zeros(2, G.nElem, G.Layup(1).nLayers,2); % Failure modes for max strain/stress criteria

% Loop over all elements and compute the values
for ElemNo = 1:G.nElem
  % Get the FE data for this element
  [E] = GetFEData(G, ElemNo, 0);
  % Get E.U containing element displacements
  [E] = GetElemU(G, A, E, 0);
  % Call the simplified element stress routine for plate models
  [E] = ElemStress(E);
  % Copy the element values to A
  A.StrainXY(:,ElemNo,:,:) = E.StrainXY;
  A.Strain12(:,ElemNo,:,:) = E.Strain12;
  A.StressXY(:,ElemNo,:,:) = E.StressXY;
  A.Stress12(:,ElemNo,:,:) = E.Stress12;
  A.SE(ElemNo,:) = E.SE(:);
  A.SED(ElemNo,:) = E.SED(:);
  A.FIdx(:,ElemNo,:,:) = E.FIdx;
  A.FIdxMode(:,ElemNo,:,:) = E.FIdxMode;
end
