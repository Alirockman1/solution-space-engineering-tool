% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [ G ] = Mesh(G)

% The FE mesh has G.nElemX elements in the length direction (x) and
% G.nElemY elements in the height direction (y).

% Determine the number of elements, G.nElem
G.nElem = G.nElemX*G.nElemY;
% We use 9-node elements with 5 DOF's per node
G.nNodesPerElem = 9;
G.nNodalDOF = 5;

% The element connectivities (element definitions) are stored in
% G.ElemConnect(ElemNo,k), k = 1,G.nMaxNodesPerElem
G.ElemConnect = zeros(G.nElem,G.nNodesPerElem);

% We have G.nElemX elements in the x-direction and G.nElemY elements
% in the y-direction.
%
% Element at position (i,j): ElemNo = (j-1)*G.nElemY + i
%
%    -> j   (i = 1,2,..,G.nElemY; j = 1,2,..,G.nElemX)
% | No4 - No7 - No3
% i  |           |
%   No8   No9   Mo6
%    |           |
%   No1 - No5 - No2
%
%  No1,..,No9 are stored in E.Nodes(1:9) and copied to G.ElemConnect(ElemNo,:)
%
% Node numbering is as follows for row i and column j of the mesh:
%
%    Generic example:                Example with G.nElemX = 3
%                                    and G.nElemY = 2:
%    -> j   (i = 1,2,..,G.nElemY; j = 1,2,..,G.nElemX)
% |  * - * - * - * - * .. - * - *     1 - 6 -11 -16 -21 -26 -31
% i  |       |       |          |     |       |       |       |
%    *   *   *   *   * ..   *   *     2   7  12  17  22  27  32
%    |  #1   |   #3  |          |     |       |       |       |
%    * - * - * - * - * .. - * - *     3 - 8 -13 -18 -23 -28 -33
%    |       |       |          |     |       |       |       |
%    *   *   *  i,j  * ..   *   *     4   9  14  19  24  29  34 
%    |  #2   |       |          |     |       |       |       |
%    * - * - * - * - * .. - * - *     5 -10 -15 -20 -25 -30 -35
% where # indicates the element number
E.Nodes = zeros(G.nNodesPerElem,1);

for j = 1:G.nElemX
  % Determine start and end node numbers for element columns j and j+1
  StartNo_j = (j-1) * (G.nElemY*4+2) + 1;
  EndNo_j = StartNo_j + G.nElemY*2;
  StartNo_jPlusOne = j * (G.nElemY*4+2) + 1;
  % Generate the 9 nodes for each element in element column j
  for i = 1:G.nElemY
    ElemNo = (j-1)*G.nElemY + i;
    E.Nodes(1) = StartNo_j + (i-1)*2 + 2;
    E.Nodes(2) = StartNo_jPlusOne + (i-1)*2 + 2;
    E.Nodes(3) = StartNo_jPlusOne + (i-1)*2;
    E.Nodes(4) = StartNo_j + (i-1)*2;
    E.Nodes(5) = EndNo_j + i*2 + 1;
    E.Nodes(6) = StartNo_jPlusOne + (i-1)*2 + 1;
    E.Nodes(7) = EndNo_j + (i-1)*2 + 1;
    E.Nodes(8) = StartNo_j + (i-1)*2 + 1;
    E.Nodes(9) = EndNo_j + (i-1)*2 + 2;
    G.ElemConnect(ElemNo,:) = E.Nodes;
  end
end
% Determine the number of nodes G.nNodes
G.nNodes = (2*G.nElemX+1)*(2*G.nElemY+1);

% The coordinates are stored in G.X(NodeNo,k), k = 1,nDim
G.X = zeros(G.nNodes,3);

% Generate the nodal coordinates. Origo is in lower left corner
G.ElemLX = G.LX/(G.nElemX);
G.ElemLY = G.LY/(G.nElemY);

NodeNo = 0;
for j = 1:2*G.nElemX+1
  for i = 1:2*G.nElemY+1
    NodeNo = NodeNo + 1;
    G.X(NodeNo,1) = (j-1)*G.ElemLX/2; % Distance G.ElemLX/2 between nodes
    G.X(NodeNo,2) = G.LY - (i-1)*G.ElemLY/2;
  end
end

% We generate the mesh grid that can be used for plotting results:
[G.XPlot, G.YPlot] = meshgrid(0.0:G.ElemLX/2:G.LX, G.LY:-G.ElemLY/2:0);

% Generate the patches (elements with the same layup)
G.PatchNo = zeros(G.nElem,1);
G.nPatches = 0;
nElemPerPatchX = G.nElemX/G.nPatchX;
nElemPerPatchY = G.nElemY/G.nPatchY;
PatchNoX = 0;
ElemNo = 0;

for j = 1:G.nElemX
  if (mod(j-1,nElemPerPatchX) == 0)
    PatchNoX = PatchNoX + 1;
  end
  PatchNoY = 0;
  for i = 1:G.nElemY
    ElemNo = ElemNo + 1;
    if (mod(i-1,nElemPerPatchY) == 0)
      PatchNoY = PatchNoY + 1;
    end
    PatchNo = (PatchNoX-1)*G.nPatchY + PatchNoY;
    % Set the patch number for the element
    G.PatchNo(ElemNo) = PatchNo;
  end
end
G.nPatches = PatchNo;
