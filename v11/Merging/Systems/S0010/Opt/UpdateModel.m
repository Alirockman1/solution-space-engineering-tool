% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [ G ] = UpdateModel(G, O, x)

%********************************************************
% File: = UpdateModel.m
%   This function updates the model based on the design variables of the model.
%
% Syntax:
%   UpdateModel(G)
%
% Input:
%   G             : Global data
%   x             : design variables
%   O.nDesVar     : number of design variables
%   O.DVType(DVNo): DVType = 1: Thickness, 2: Angle, 3: DMO
%
% Output:
%   G        : Global data are updated (G.Layup)
%   O.x      : x is copied to O.x
%
% Revisions:
%   Version 1.0    05.02.2016   Erik Lund

for DVNo = 1:O.nDesVar

  % Find the patch and layer number
  PatchNo = O.PatchNo(DVNo);
  k = O.LayerNo(DVNo);
    
  switch O.DVType(DVNo)
    case 1 % Thickness design variable
      G.Layup(PatchNo).t(k) = x(DVNo);
      if (G.SymLayup == 1)
        k = G.Layup(PatchNo).nLayers - k + 1;
        G.Layup(PatchNo).t(k) = x(DVNo);
      end
    case 2 % Angle design variable
      G.Layup(PatchNo).Angle(k) = x(DVNo);
      if (G.SymLayup == 1)
        k = G.Layup(PatchNo).nLayers - k + 1;
        G.Layup(PatchNo).Angle(k) = x(DVNo);
      end
    %case 3 % DMO design variable
        
    otherwise
      disp('Error in design variable bookkeeping');
  end
  
end

% Copy x to O.x
O.x = x;


