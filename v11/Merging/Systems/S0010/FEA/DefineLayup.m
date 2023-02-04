% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [ G ] = DefineLayup(G, nLayers, tPly, MatNo, Angle)

%********************************************************
% File: DefineLayup.m
%   This function generates the layup for all elements in the model.
%
% Syntax:
%   DefineLayup(G, nLayers, Thick, MatNo, Angle)
%
% Input:
%   G                : Global data
%   nLayers          : Number of layers. 
%                      If G.SymLayup = 1, then nLayers is doubled
%   tPly(1:nLayers)  : Thickness of each layer/ply
%   MatNo(1:nLayers) : The material number (1: alu, 2: CFRP)
%   Angle(1:nLayers) : Fiber angle
%
% Output:
%   G.Layup(1:G.nPatches): The layup for all patches

% The layup is defined
if (G.SymLayup == 1)
  % If symmetric layup, the input vctors define the lower part of the laminate
  G.Layup.nLayers = 2*nLayers;
  % We flip the input vectors in order to generate a symmetric layup
  tPlySym = fliplr(tPly);
  MatNoSym = fliplr(MatNo);
  AngleSym = fliplr(Angle);
else
  G.Layup.nLayers = nLayers;
end
% Copy the input vectors to G.Layup
G.Layup.t(1:nLayers) = tPly(1:nLayers);
G.Layup.MatNo(1:nLayers) = MatNo(1:nLayers);
G.Layup.Angle(1:nLayers) = Angle(1:nLayers);
G.Layup.tTotal = sum(tPly(1:nLayers));
% If symmetric layup, copy the flipped vectors to G.Layup
if (G.SymLayup == 1)
  G.Layup.tTotal = 2*G.Layup.tTotal;
  G.Layup.t(nLayers+1:2*nLayers) = tPlySym(1:nLayers);
  G.Layup.MatNo(nLayers+1:2*nLayers) = MatNoSym(1:nLayers);
  G.Layup.Angle(nLayers+1:2*nLayers) = AngleSym(1:nLayers);
end

% Bookkeeping for DMO parameterization is added
G.Layup.DMO = 0;
G.Layup.FirstDMOVar(1:G.Layup.nLayers) = -1;

% We copy this layup to all patches. In case of elementwise 
% parameterization, then G.nPatches = G.nElem
if (G.nPatches > 1)
  for PatchNo = 2:G.nPatches
    G.Layup(PatchNo) = G.Layup(1);
  end
end