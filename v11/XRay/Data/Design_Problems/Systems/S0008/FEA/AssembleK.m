% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [A] = AssembleK(G, A)
% This function assembles the global system matrix, i.e. contributions from the
% element matrix are added to the global system of equations.
% Input:  G : Global data
%         A : Analysis data
% Output: A : A.K, A.i, A.j and A.Kij

% We loop over all finite elements and store each element stiffness matrix
% in vector format, as the assembly then is much faster. 
% The bookkeeping and vector assembly of the stiffness matrix are inspired 
% by Ole Sigmund's 99 line Matlab topology optimization code, 
% see http://www.topopt.mek.dtu.dk/Apps-and-software/A-99-line-topology-optimization-code-written-in-MATLAB
% and http://www.topopt.mek.dtu.dk/Apps-and-software/Efficient-topology-optimization-in-MATLAB.

% The size of each element matrix is ElemKSize.

ElemKSize = (G.nNodesPerElem*G.nNodalDOF)^2;
A.i = zeros(G.nElem*ElemKSize,1);
A.j = zeros(G.nElem*ElemKSize,1);
A.Kij = zeros(G.nElem*ElemKSize,1);

nTriplets = 0;
for ElemNo = 1:G.nElem
  % Get the FE data for this element
  [E] = GetFEData(G, ElemNo, 0);
  % Call the simplified element stiffness routine for plate models
  [E, CLayerLoc] = ElemK(E);
  A.CLayerLoc = CLayerLoc;
  % Alternatively, call the general shell element stiffness routine 
  %[E] = ElemK_Shell(E);

  % Store element stiffness matrix E.K using A.i, A.j and A.Kij
  for krow = 1:E.nElemDOF
    for kcol = 1:E.nElemDOF
      nTriplets = nTriplets+1;
      A.i(nTriplets) = E.DOF(krow);
      A.j(nTriplets) = E.DOF(kcol);
      A.Kij(nTriplets) = E.K(krow,kcol);
    end
  end
end

% Assemble the sparse stiffness matrix A.K using A.i, A.j and A.Kij
A.K = sparse(A.i, A.j, A.Kij, A.nDOFs, A.nDOFs);
