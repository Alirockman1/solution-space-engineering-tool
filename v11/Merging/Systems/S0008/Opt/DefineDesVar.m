% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [G, O] = DefineDesVar(G, ThickDV, AngleDV, DMODV, MoveLimit)

%********************************************************
% This function generates the design variables of the model.
% Input:
%   G        : Global data
%   O        : Optimization data
%   ThickDV  : 1 if thickness design variables are wanted, otherwise 0
%   AngleDV  : 1 if Angle design variables are wanted, otherwise 0
%   DMODV    : 1 if DMO variables (default: 4 angles) are wanted, otherwise 0
%   MoveLimit: Move limit for all design variables. You may also define
%              them explicitly for each group of design variables below.
%
% Output:
%   G        : Global data
%   O        : Optimization data
%   O.nDesVar: The number of design variables
%   O.DesVar : The design variables
%

% Check the input (design variable specs must be 0 or 1)
Classes = {'int8'};
Attributes = {'>',-1,'<',2};
FuncName = 'DefineDesVar';
O.WantedDVs = [int8(ThickDV); int8(AngleDV); int8(DMODV)];

validateattributes(O.WantedDVs,Classes,Attributes,FuncName)

% Calculate the total number of design domains (number of patches times
% number of layers)
O.nDesignDomains = 0;
for PatchNo = 1:G.nPatches
  O.nDesignDomains = O.nDesignDomains + G.Layup(PatchNo).nLayers;
end
% For symmetric layups we only have half the number of design domains
if (G.SymLayup == 1)
  O.nDesignDomains = O.nDesignDomains/2;
end

% Count the layerwise thickness and/or angle design variables
O.nDesVar = O.nDesignDomains*sum(double(O.WantedDVs(1:2)));

% DMO bookkeeping is implemented but not used for the example scripts
if (DMODV > 0)
  G.DMODV = DMODV; % Added to G, such that we know if DMO optimization is done
  % O.nDMOVar(k): number of DMO variables (here discrete candidate angles)
  %nDMOVar  = 4; % nDMOVar could be input argument to this function
  % O.nDMOVar(1:G.Layup(1).nLayers) = nDMOVar;
  % Update the total number of design variables
  O.nDesVar = O.nDesVar + O.nDesignDomains*(O.nDMOVar(1));
  switch (O.nDMOVar(1))
    case 1
      AngleOffset = 0;
    case 2
      AngleOffset = 0;
    case 3
      AngleOffset = -60;
    case 4
      AngleOffset = -45;
    otherwise
      AngleOffset = -90;
  end
end

% Initialize the design variables
% O.x    : design variables
% O.Lower: lower limits
% O.Upper: upper limits
% O.PatchNo(DVNo): number of the associated section = the element number
% O.LayerNo(DVNo): number of the associated layer, if thickness or angle
%                  design variable
% O.DVType(DVNo) : DVType = 1: Thickness, 2: Angle, 3: DMO
% O.Pert(DVNo)   : The perturbation used in finite difference approxs.

% Initialize all vectors
O.x = zeros(O.nDesVar,1);
O.Lower = zeros(O.nDesVar,1);
O.Upper = zeros(O.nDesVar,1);
O.PatchNo = zeros(O.nDesVar,1);
O.LayerNo = zeros(O.nDesVar,1);
O.DVType = zeros(O.nDesVar,1);
O.Pert = zeros(O.nDesVar,1);

% DVNo is the counter of the design variable
DVNo = 0;

if (G.SymLayup == 1)
  nLayers = G.Layup(1).nLayers/2; % All patches have the same number of layers
else
  nLayers = G.Layup(1).nLayers;
end

% Check the move limit
if (MoveLimit > 1 || MoveLimit < 0)
  disp('Move limit should be within [0;1]. Reset to 0.1')
  MoveLimit = 0.1;
end

% Loop over the layers and assign design variables
for PatchNo = 1:G.nPatches
  for k = 1:nLayers
    if (ThickDV > 0) 
      DVNo = DVNo + 1;
      O.x(DVNo) = G.Layup(PatchNo).t(k);
      O.Lower(DVNo) = 1E-6;                     % Default: nearly 0
      O.Upper(DVNo) = 5*G.Layup(PatchNo).t(k);  % Default: 5 times thicker
      O.PatchNo(DVNo) = PatchNo;
      O.LayerNo(DVNo) = k;
      O.DVType(DVNo) = 1;            % Thickness design variable
      O.Pert(DVNo) = O.x(DVNo)*1E-3; % Perturbation used in SA DSA
      O.ML(DVNo) = MoveLimit;        % Move limit, 0.05 = 5%
    end % if (ThickDV > 0)
    if (AngleDV > 0)
      DVNo = DVNo + 1;               % Angles are in degrees
      O.x(DVNo) = G.Layup(PatchNo).Angle(k);
      O.Lower(DVNo) = O.x(DVNo)-100; % We set lower and upper limits to
      O.Upper(DVNo) = O.x(DVNo)+100; % 100 degree from the current angle
      O.PatchNo(DVNo) = PatchNo;     % (more than 90 degree, hopefully the
      O.LayerNo(DVNo) = k;           % box constraints do not become active)
      O.DVType(DVNo) = 2;            % Angle design variable
      O.Pert(DVNo) = 0.01;           % Perturbation used in SA DSA 
      O.ML(DVNo) = MoveLimit;        % Move limit, e.g. 0.20 = 20%
    end % if (AngleDV > 0)
    if (DMODV > 0)
      G.Layup(PatchNo).DMO = 1;
      G.Layup(PatchNo).Layer(k).DMOVar(1:O.nDMOVar(1)) = 1.0/O.nDMOVar(1);
      FirstDMOVar = DVNo + 1;
      LastDMOVar = DVNo + O.nDMOVar(1);
      G.Layup(PatchNo).FirstDMOVar(k) = FirstDMOVar;
      for i = 1:O.nDMOVar(k)
        DVNo = DVNo + 1;
        O.FirstDMOVar(DVNo) = FirstDMOVar;
        O.LastDMOVar(DVNo) = LastDMOVar;
        % Currently DMO variables are candidate angles
        O.DMOAngle(DVNo) = AngleOffset + (i-1)*180.0/O.nDMOVar(k);
        % We can check the implementation here by setting one of
        % O.x(1:DVNo) to 1 and the others to 0
        O.x(DVNo) = 1.0/O.nDMOVar(k); % SIMP scheme - same x_i initially
        O.Lower(DVNo) = 0;
        O.Upper(DVNo) = 1;
        O.PatchNo(DVNo) = PatchNo;
        O.LayerNo(DVNo) = k;
        O.DVType(DVNo) = 3; % DMO design variable
        O.Pert(DVNo) = 0.001; % Should be implemented analytically...
        O.ML(DVNo) = 0.1; % Move limit
      end % loop for i
    end % if (DMODV > 0)
  end % loop for k
end % loop for PatchNo

% We create a list of elements linked to each design variable. This is done
% according to patch numbers of each element.
O.DVInfo(1).nPatchToElemLinks = 0;
for DVNo = 2:O.nDesVar
  O.DVInfo(DVNo) = O.DVInfo(1);
end

% Create a histogram of G.PatchNo, such that nPatchToElemLinks contains the
% number of element links to each PatchNo listed in PatchNoVec
[nPatchToElemLinks,PatchNoVec] = hist(G.PatchNo,unique(G.PatchNo));

% Create the element lists O.DVInfo(DVNo).ElemList
for DVNo = 1:O.nDesVar
  PatchNo = O.PatchNo(DVNo);
  % Find the location of PatchNo in the vector PatchNoVec
  PatchNoLoc = find(PatchNoVec == PatchNo);
  O.DVInfo(DVNo).nPatchToElemLinks = nPatchToElemLinks(PatchNoLoc);
  % Allocate the list of element numbers linked to this patch
  O.DVInfo(DVNo).ElemList = zeros(nPatchToElemLinks(PatchNoLoc));
  % Store the list of associated elements in the list O.ElemList(DVNo)
  O.DVInfo(DVNo).ElemList = find(PatchNo == G.PatchNo);
end
