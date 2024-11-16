% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [E] = GetFEData(G, ElemNo, Mode)
% Input:  G     : Global data
%         ElemNo: the element number
%         Mode  : Current mode: 0: Analysis
%                               1: SA DSA
%                               2: Analytical DSA
% Output: E     : element data

E.nNodes = G.nNodesPerElem;        % 9 nodes
E.nNodalDOF = G.nNodalDOF;         % 5 DOFs per node
E.nElemDOF = E.nNodes*E.nNodalDOF; % each element has 45 DOF's

% E.Nodes contains the list of nodes defining the element
E.Nodes = G.ElemConnect(ElemNo,:);

% E.X contains element nodal coordinates
E.X(1:E.nNodes,1:3) = G.X(E.Nodes,1:3);

% The material properties are copied to the element
E.Mat = G.Mat; 

% Get the layup for the element
E.PatchNo = G.PatchNo(ElemNo);
E.Layup = G.Layup(E.PatchNo);

E.DOF = zeros(E.nElemDOF,1);

% Copy DOF numbers to E.DOF
i = 0;
for NodeNo = 1:E.nNodes
  for DOFNo = 1:E.nNodalDOF
    i = i+1;
    E.DOF(i) = E.nNodalDOF*(E.Nodes(NodeNo)-1)+DOFNo;
  end
end

% Copy the mode to the element, 0: analysis, 1: SA DSA, 2: analytical DSA, etc.
E.Mode = Mode;

% For the plate models the element area is easy to compute :-)
E.Area = G.ElemLX*G.ElemLY;
