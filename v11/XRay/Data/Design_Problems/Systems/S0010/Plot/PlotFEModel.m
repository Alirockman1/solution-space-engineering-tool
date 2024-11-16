% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function PlotFEModel(G, PlotElem, PlotNodes)

% This function plots the FE model. The element contours and nodes are
% always plotted. 
%
% Input:  G        : Global data
%         PlotElem : If 1, then plot element numbers
%         PlotNodes: If 1, then plot node numbers

figure()
% Add x- and y-coordinates as labels
%xlabel('x-coordinate')
%ylabel('y-coordinate')
% We try to scale font size, etc., to the discretization
CharSize = max(G.nElemX,G.nElemY);
% Node font size varying from around 17 to 5 pt
MyNodeFontSize = max(-10/(25)*CharSize+17,5); 
% Element font size varying from around 17 to 5 pt
MyElemFontSize = max(-10/(25)*CharSize+17,5); 
% Node circle size varying from around 4 to 1
MyMarkerSize = max(-1/5*CharSize+4,1); 
if (PlotNodes)
  alignx = 0.04;  % fraction of element length to move text
  aligny = 0.07;
else
  alignx = 0.02;
  aligny = 0;
end

hold on
for ElemNo=1:G.nElem
  E.Nodes = G.ElemConnect(ElemNo,:);
    
  x = [G.X(E.Nodes(1),1) G.X(E.Nodes(5),1) G.X(E.Nodes(2),1) G.X(E.Nodes(6),1)...
       G.X(E.Nodes(3),1) G.X(E.Nodes(7),1) G.X(E.Nodes(4),1) G.X(E.Nodes(8),1)];
  y = [G.X(E.Nodes(1),2) G.X(E.Nodes(5),2) G.X(E.Nodes(2),2) G.X(E.Nodes(6),2)...
       G.X(E.Nodes(3),2) G.X(E.Nodes(7),2) G.X(E.Nodes(4),2) G.X(E.Nodes(8),2)];
  fill(x,y,'w')
  % Plot nodes and their numbers, if wanted
  if (PlotNodes)
    for NodeNo = 1:9
      Number = sprintf('%i',E.Nodes(NodeNo));
      plot(G.X(E.Nodes(NodeNo),1),G.X(E.Nodes(NodeNo),2),'ko','linewidth',2,'MarkerSize',MyMarkerSize)
      text(G.X(E.Nodes(NodeNo),1)+G.ElemLX*alignx,G.X(E.Nodes(NodeNo),2)+G.ElemLY*aligny,Number,'fontsize',MyNodeFontSize)
    end
  end
  % Plot element number, if wanted
  if (PlotElem)
    Number = sprintf('%i',ElemNo);
    text(G.X(E.Nodes(9),1)-5*G.ElemLX*alignx,G.X(E.Nodes(9),2)+2*G.ElemLY*aligny,Number,'Color','red','fontsize',MyElemFontSize)
  end
end
axis off
axis equal
hold off

