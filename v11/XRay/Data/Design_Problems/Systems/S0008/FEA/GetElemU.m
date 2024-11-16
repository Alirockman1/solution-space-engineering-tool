% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [E] = GetElemU(G, A, E, Mode)
% Input:  G     : Global data
%         A     : Analysis data
%         E     : Element data
%         Mode  : 0/1, then get E.U, 2: also get E.DUDx from A.DUDx    
% Output: E     : element data, in particular E.U

% This function assumes that GetFEData has been called

E.U = zeros(E.nElemDOF,1);
% Copy components of A.U to element vector E.U
i = 0;
for NodeNo = 1:E.nNodes
  for DOFNo = 1:5
    i = i+1;
    E.U(5*(NodeNo-1)+DOFNo) = A.U(E.DOF(i));
  end
end
	
if (Mode == 2)
  E.DUDx = zeros(E.nElemDOF,1);
  % Copy components of A.U to element vector E.U
  i = 0;
  for NodeNo = 1:E.nNodes
    for DOFNo = 1:5
      i = i+1;
      E.DUDx(5*(NodeNo-1)+DOFNo) = A.DUDx(E.DOF(i));
    end
  end
end

end