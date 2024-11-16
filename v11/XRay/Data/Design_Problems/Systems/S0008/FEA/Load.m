% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [A] = Load(G, A, LoadBC, ScaleFac)

% This function determines the load for model G.ModelNo.
% Input:  G     : Global data
%         A     : Analysis data
%         LoadBC: The load to apply
%                 1 (point load FY at mid point of right edge)
%                 2 (point load FZ at mid point of right edge)
%                 3 (point load FZ at mid point of plate)
%                 4 (constant pressure P at plate surface)
%                 5 (constant extensional load/length N_x at right edge)
%                 6 (constant transverse load/length N_y at right edge)
%                 7 (constant extensional load/length N_y at upper edge)
%         ScaleFac is the scaling of the default unit load/pressure applied 
% Output: A.F is updated (it is initialized before calling this function)

switch LoadBC
  case 1
    % Point load FY at the middle of the right edge  
    % Determine start and end node numbers of the right edge
    StartNo = G.nElemX * (G.nElemY*4+2) + 1;
    EndNo = StartNo + G.nElemY*2;
    MidNodeNo = round((StartNo + EndNo)/2);
    DOFNo = 5*(MidNodeNo-1)+2;
    A.F(DOFNo) = A.F(DOFNo) + ScaleFac;
    
  case 2
    % Point load FZ at the middle of the right edge
    StartNo = G.nElemX * (G.nElemY*4+2) + 1;
    EndNo = StartNo + G.nElemY*2;
    MidNodeNo = round((StartNo + EndNo)/2); 
    DOFNo = 5*(MidNodeNo-1)+3;
    A.F(DOFNo) = A.F(DOFNo) + ScaleFac;
    
  case 3
    % Point load FZ at the mid point of the plate
    MidNodeNo = (G.nElemX * (G.nElemY*4+2) + G.nElemY*2 + 2)/2;
    DOFNo = 5*(MidNodeNo-1)+3;
    A.F(DOFNo) = A.F(DOFNo) + ScaleFac;
  
  case 4
    % Constant pressure P (negative FZ) at plate surface
    for ElemNo = 1:G.nElem
      E.Nodes = G.ElemConnect(ElemNo,:);
      Area = G.ElemLX*G.ElemLY;
      % Corner nodes get 1/36, midside nodes 1/9 and center node 4/9 of
      % total pressure (Area*ScaleFac)
      for i = 1:4
        NodeNo = E.Nodes(i);
        DOFNo = 5*(NodeNo-1)+3;
        A.F(DOFNo) = A.F(DOFNo) - Area*ScaleFac/36;
      end
      for i = 5:8
        NodeNo = E.Nodes(i);
        DOFNo = 5*(NodeNo-1)+3;
        A.F(DOFNo) = A.F(DOFNo) - Area*ScaleFac/9;
      end
      NodeNo = E.Nodes(9);
      DOFNo = 5*(NodeNo-1)+3;
      A.F(DOFNo) = A.F(DOFNo) - Area*ScaleFac*4/9;
    end
    
  case 5
    % Constant extensional load/length N_x at right edge
    StartNo = G.nElemX * (G.nElemY*4+2) + 1;
    E.Nodes(1:3) = 0;
    NodeNo = StartNo;
    % Corner nodes get 1/6 while midnode get 2/3 of total load/length (ScaleFac*G.ElemLY)
    for ElemNo = 1:G.nElemY
      for i = 1:3
        E.Nodes(i) = NodeNo;
        NodeNo = NodeNo + 1;
      end
      % The midnode gets 2/3
      NodeNo = E.Nodes(2);
      DOFNo = 5*(NodeNo-1)+1;
      A.F(DOFNo) = A.F(DOFNo) + ScaleFac*G.ElemLY*2/3;
      % The corner nodes get 1/3
      for i = 1:2:3
        NodeNo = E.Nodes(i);
        DOFNo = 5*(NodeNo-1)+1;
        A.F(DOFNo) = A.F(DOFNo) + ScaleFac*G.ElemLY/6;
      end
    end
    
  case 6
    % Constant transverse load/length N_y at right edge
    StartNo = G.nElemX * (G.nElemY*4+2) + 1;
    E.Nodes(1:3) = 0;
    NodeNo = StartNo;
    % Corner nodes get 1/6 while midnode get 2/3 of total load/length (ScaleFac*G.ElemLY)
    for ElemNo = 1:G.nElemY
      for i = 1:3
        E.Nodes(i) = NodeNo;
        NodeNo = NodeNo + 1;
      end
      % The midnode gets 2/3
      NodeNo = E.Nodes(2);
      DOFNo = 5*(NodeNo-1)+2;
      A.F(DOFNo) = A.F(DOFNo) + ScaleFac*G.ElemLY*2/3;
      % The corner nodes get 1/3
      for i = 1:2:3
        NodeNo = E.Nodes(i);
        DOFNo = 5*(NodeNo-1)+2;
        A.F(DOFNo) = A.F(DOFNo) + ScaleFac*G.ElemLY/6;
      end
    end

  case 7
    % constant extensional load/length N_y at upper edge
    StartNo = 1; % First node number
    NodeInc = G.nElemY*2+1;  % Node increment
    E.Nodes(1:3) = 0;
    NodeNo = StartNo;
    % Corner nodes get 1/6 while midnode get 2/3 of total load/length (ScaleFac*G.ElemLX)
    for ElemNo = 1:G.nElemX
      for i = 1:3
        E.Nodes(i) = NodeNo;
        NodeNo = NodeNo + NodeInc;
      end
      % The midnode gets 2/3
      NodeNo = E.Nodes(2);
      DOFNo = 5*(NodeNo-1)+2;
      A.F(DOFNo) = A.F(DOFNo) + ScaleFac*G.ElemLX*2/3;
      % The corner nodes get 1/3
      for i = 1:2:3
        NodeNo = E.Nodes(i);
        DOFNo = 5*(NodeNo-1)+2;
        A.F(DOFNo) = A.F(DOFNo) + ScaleFac*G.ElemLX/6;
      end
    end

    case 8
    % constant extensional load/length N_y at LEFT edge
    StartNo = 1; % First node number
    NodeInc = 1;  % Node increment
    E.Nodes(1:3) = 0;
    NodeNo = StartNo;
    % Corner nodes get 1/6 while midnode get 2/3 of total load/length (ScaleFac*G.ElemLX)
    for ElemNo = 1:G.nElemX
      for i = 1:3
        E.Nodes(i) = NodeNo;
        NodeNo = NodeNo + NodeInc;
      end
      % The midnode gets 2/3
      NodeNo = E.Nodes(2);
      DOFNo = 5*(NodeNo-1)+2;
      A.F(DOFNo) = A.F(DOFNo) - ScaleFac*G.ElemLY*2/3;
      % The corner nodes get 1/3
      for i = 1:2:3
        NodeNo = E.Nodes(i);
        DOFNo = 5*(NodeNo-1)+2;
        A.F(DOFNo) = A.F(DOFNo) - ScaleFac*G.ElemLY/6;
      end
    end

    case 9
    % constant extensional load/length N_y at LOWER edge
    StartNo = G.nElemY*2+1; % First node number
    NodeInc = G.nElemY*2+1;  % Node increment
    E.Nodes(1:3) = 0;
    NodeNo = StartNo;
    % Corner nodes get 1/6 while midnode get 2/3 of total load/length (ScaleFac*G.ElemLX)
    for ElemNo = 1:G.nElemX
      for i = 1:3
        E.Nodes(i) = NodeNo;
        NodeNo = NodeNo + NodeInc;
      end
      % The midnode gets 2/3
      NodeNo = E.Nodes(2);
      DOFNo = 5*(NodeNo-1)+2;
      A.F(DOFNo) = A.F(DOFNo) - ScaleFac*G.ElemLX*2/3;
      % The corner nodes get 1/3
      for i = 1:2:3
        NodeNo = E.Nodes(i);
        DOFNo = 5*(NodeNo-1)+2;
        A.F(DOFNo) = A.F(DOFNo) - ScaleFac*G.ElemLX/6;
      end
    end
    
    case 10
    % Constant extensional load/length N_z at right edge
    StartNo = G.nElemX * (G.nElemY*4+2) + 1;
    E.Nodes(1:3) = 0;
    NodeNo = StartNo;
    % Corner nodes get 1/6 while midnode get 2/3 of total load/length (ScaleFac*G.ElemLY)
    for ElemNo = 1:G.nElemY
      for i = 1:3
        E.Nodes(i) = NodeNo;
        NodeNo = NodeNo + 1;
      end
      % The midnode gets 2/3
      NodeNo = E.Nodes(2);
      DOFNo = 5*(NodeNo-1)+3;
      A.F(DOFNo) = A.F(DOFNo) + ScaleFac*G.ElemLY*2/3;
      % The corner nodes get 1/3
      for i = 1:2:3
        NodeNo = E.Nodes(i);
        DOFNo = 5*(NodeNo-1)+3;
        A.F(DOFNo) = A.F(DOFNo) + ScaleFac*G.ElemLY/6;
      end
    end
    
  otherwise
    disp('This load is not yet implemented')
    stop
end
