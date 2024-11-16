% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [ G ] = PerturbDesVar(G, O, DVNo, Factor)

%********************************************************
% File: = PerturbDesVar.m
%   This function perturbs the model for a given design variable.
%
% Syntax:
%   PerturbDesVar(G, O, DVNo)
%
% Input:
%   G             : Global data
%   O.x           : design variables
%   DVNo          : Design variable number
%   Factor        : Typically 1 or -1: scaling factor on O.Pert(DVNo)
%
% Output:
%   G        : Global data

% Find the patch and layer number
PatchNo = O.PatchNo(DVNo);
k = O.LayerNo(DVNo);

switch O.DVType(DVNo)
  case 1 % Thickness design variable
    G.Layup(PatchNo).t(k) = G.Layup(PatchNo).t(k) + ...
                            Factor*O.Pert(DVNo);
    if (G.SymLayup == 1)
      k = G.Layup(PatchNo).nLayers - k + 1;
      G.Layup(PatchNo).t(k) = G.Layup(PatchNo).t(k) + ...
                              Factor*O.Pert(DVNo);
    end
  case 2 % Angle design variable
    G.Layup(PatchNo).Angle(k) = G.Layup(PatchNo).Angle(k) + ...
                                Factor*O.Pert(DVNo);
    if (G.SymLayup == 1)
      k = G.Layup(PatchNo).nLayers - k + 1;
      G.Layup(PatchNo).Angle(k) = G.Layup(PatchNo).Angle(k) + ...
                                  Factor*O.Pert(DVNo);
    end
    
  %case 3 % DMO design variable
  otherwise
    disp('Error in design variable bookkeeping');
end    
   
