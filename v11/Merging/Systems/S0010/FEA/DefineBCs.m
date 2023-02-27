% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [G, A] = DefineBCs(G, DispBC)

% This function defines the boundary conditions.
% Input:  G     : Global data
%         A     : Analysis data
%         DispBC: The displacement BCs to use
%                 1: 2D cantilever: left edge completely fixed and UZ=RX=RY=0
%                 2: Cantilever: left edge completely fixed
%                 3: Clamped plate: all edges completely fixed
%                 4: Simply supported plate
%                 5: UX = 0 at left edge, UY = 0 at lower edge and lower left node is fixed
% Output: A.nDOFs , A.AllDOFs, A.FixedDOFs, and A.FreeDOFs

% The DOFs (Degrees-Of-Freedom) are in the following order for each node: 
% UX, UY, UZ, RX, RY where RX and RY are local rotations.
% DOF numbering is as follows (5 DOFs per node):

%    Example with G.nElemX = 3 and G.nElemY = 2:
% 
%  (1-5)  - (26-30) - (51-55) - (76-80) - (101-105) - (126-130) - (151-155)
%    |                   |                    |                       |
%  (6-10)   (31-35)   (56-60)   (81-85)   (106-110)   (131-135)   (156-160)
%    |                   |                    |                       |
% (11-15) - (36-40) - (61-65) - (86-90) - (111-115) - (136-140) - (161-165)
%    |                   |                    |                       |
% (16-20)   (41-45)   (66-70)   (91-95)   (116-120)   (141-145)   (166-170)
%    |                   |                    |                       |
% (21-25) - (46-50) - (71-75) - (96-100)- (121-125) - (146-150) - (171-175)

% Store the number of DOFs in the model (G.nNodalDOF = 5)
A.nDOFs = 5*G.nNodes;

% Initialize A.AllDOFs containing all equation numbers
A.AllDOFs = [1:A.nDOFs];

% Set A.FixedDOF containing the list of all prescribed (zero) DOFs
switch DispBC
  case 1
    % 2D cantilever (2D model). The left edge is completely clamped
	A.nFixedDOFs = 2*(G.nElemY*2+1) + 3*G.nNodes;
	A.FixedDOFs = zeros(A.nFixedDOFs,1);
	i = 0;
    for NodeNo = 1:G.nElemY*2+1
	  for DOFNo = 1:5
        i = i + 1;
        A.FixedDOFs(i) = (NodeNo-1)*5 + DOFNo;
	  end
    end
    % Only in-plane DOF's for a 2D model, i.e. UZ=RX=RY=0:
    for NodeNo = G.nElemY*2+2:G.nNodes
	  for DOFNo = 3:5
        i = i + 1;
        A.FixedDOFs(i) = (NodeNo-1)*5 + DOFNo;
	  end
    end

  case 2
    % 2D cantilever plate. The left edge is completely clamped
	A.nFixedDOFs = 5*(G.nElemY*2+1);
	A.FixedDOFs = zeros(A.nFixedDOFs,1);
	A.FixedDOFs = [1:5*(G.nElemY*2+1)]; 

  case 3
    % Clamped plate. All edges are completely clamped
	A.nFixedDOFs = 2*5*(G.nElemY*2+1) + 2*5*(G.nElemX*2-1);
	A.FixedDOFs = zeros(A.nFixedDOFs,1);
    % Left edge
	i = 0;
    for NodeNo = 1:G.nElemY*2+1
	  for DOFNo = 1:5
        i = i + 1;
        A.FixedDOFs(i) = (NodeNo-1)*5 + DOFNo;
      end
    end
    % Upper edge and lower edge
    StartNo = G.nElemY*2+2;
    Step = G.nElemY*2+1;
    EndNo = G.nElemX * (G.nElemY*4+2) - Step + 1;
    for NodeNo = StartNo:Step:EndNo
	  for DOFNo = 1:5
        i = i + 1;
        A.FixedDOFs(i) = (NodeNo-1)*5 + DOFNo;
      end
	  for DOFNo = 1:5
        i = i + 1;
        A.FixedDOFs(i) = (NodeNo+Step-2)*5 + DOFNo;
      end
    end
    % Right edge
    StartNo = G.nElemX * (G.nElemY*4+2) + 1;
    EndNo = StartNo + G.nElemY*2;
    for NodeNo = StartNo:EndNo
	  for DOFNo = 1:5
        i = i + 1;
        A.FixedDOFs(i) = (NodeNo-1)*5 + DOFNo;
      end
    end
    
  case 4
    % Simply supported plate
	A.nFixedDOFs = 2*2*(G.nElemY*2+1) + 2*2*(G.nElemY*2-1) + 2;
	A.FixedDOFs = zeros(A.nFixedDOFs,1);

    % Upper left corner fixed inplane (UX=UY=0)
	i = 0;
    for DOFNo = 1:2
      i = i + 1;
      A.FixedDOFs(i) = DOFNo;
    end
    % Left edge (local rotation RY = 0 and UZ = 0)
    for NodeNo = 1:G.nElemY*2+1
      for DOFNo = 3:2:5
        i = i + 1;
        A.FixedDOFs(i) = (NodeNo-1)*5 + DOFNo;
      end
    end
    % Right edge (local rotation RY = 0 and UZ = 0)
    StartNo = G.nElemX * (G.nElemY*4+2) + 1;
    EndNo = StartNo + G.nElemY*2;
    for NodeNo = StartNo:EndNo
      for DOFNo = 3:2:5
        i = i + 1;
        A.FixedDOFs(i) = (NodeNo-1)*5 + DOFNo;
      end
    end
    % Upper edge (local rotation RX = 0 and UZ = 0)
    Step = G.nElemY*2+1;
    EndNo = G.nElemX * (G.nElemY*4+2) + 1;
    for NodeNo = 1:Step:EndNo
      for DOFNo = 3:4
        i = i + 1;
        A.FixedDOFs(i) = (NodeNo-1)*5 + DOFNo;
      end
    end
    % Lower edge (local rotation RX = 0 and UZ = 0)
    StartNo = G.nElemY*2+1;
    Step = G.nElemY*2+1;
    EndNo = (2*G.nElemX+1)*(2*G.nElemY+1);
    for NodeNo = StartNo:Step:EndNo
      for DOFNo = 3:4
        i = i + 1;
        A.FixedDOFs(i) = (NodeNo-1)*5 + DOFNo;
      end
    end

 case 5
    % UX = 0 at left edge, UY = 0 at lower edge and lower left node is fixed
	A.nFixedDOFs = (G.nElemY*2+1) + (G.nElemX*2-1) + 3;
	A.FixedDOFs = zeros(A.nFixedDOFs,1);
    % Left edge: UX = 0
	i = 0;
    for NodeNo = 1:G.nElemY*2+1
      i = i + 1;
      A.FixedDOFs(i) = (NodeNo-1)*5 + 1;
    end
    % Lower edge: UY = 0
    StartNo = G.nElemY*2+1;
    Step = G.nElemY*2+1;
    EndNo = G.nElemX * (G.nElemY*4+2) + Step;
    for NodeNo = StartNo:Step:EndNo
      i = i + 1;
      A.FixedDOFs(i) = (NodeNo-1)*5 + 2;
    end
    % Lower left node is also fixed for the last 3 DOFs
    NodeNo = G.nElemY*2+1;
    for DOFNo = 3:5
      i = i + 1;
      A.FixedDOFs(i) = (NodeNo-1)*5 + DOFNo;
    end

    case 6
        % 2D bending test. The left side ist stationary, but moments are
        % possible
%         A.nFixedDOFs = 4*(G.nElemY*2+1);
        
        % option 2
        A.nFixedDOFs = 3*(G.nElemY*2+1)+1;

% 	    A.nFixedDOFs = 3*(G.nElemY*2+1);
% 	    A.FixedDOFs = zeros(A.nFixedDOFs,1);
        for i = 1:G.nElemY*2+1
            A.FixedDOFs(3*i-2:3*i) = 5*i-4:5*i-2;
        end
% 	    A.FixedDOFs = [1:3*(G.nElemY*2+1)];

        % add right side with only restricting z movement
        % Right edge

%         A.FixedDOFs(3*(G.nElemY*2+1)+1:4*(G.nElemY*2+1)) = 5*...
%             ((2*G.nElemX * (G.nElemY*2+1) + 1):...
%             ((2*G.nElemX+1) * (G.nElemY*2+1))) - 2;


        % only middle point on right side
        A.FixedDOFs(A.nFixedDOFs) = 5*...
            (((2*G.nElemY+1) * 2*G.nElemX) + G.nElemY + 1)...
             - 2;


%         StartNo = G.nElemX * (G.nElemY*4+2) + 1;
%         EndNo = StartNo + G.nElemY*2;
%         for NodeNo = StartNo:EndNo
% 	        for DOFNo = 1:5
%                 i = i + 1;
%                 A.FixedDOFs(i) = (NodeNo-1)*5 + DOFNo;
%             end
%         end
    
  otherwise
    disp('This model is not yet implemented')
    stop
end      

% Find the free DOFs and store them in A.FreeDOFs
A.FreeDOFs = setdiff(A.AllDOFs,A.FixedDOFs);

