% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function PlotNodeVec(G, NodeVec)

% This function plots a node vector using the patch function. 
% The figure is drawn to scale and element contours are included. 
%
% Input:  G      : Global data
%         NodeVec: The vector containing node values

figure()
title('Node values');
colormap jet

v = G.X;
f = zeros(G.nElem,4);
c = NodeVec;

hold on
for ElemNo=1:G.nElem
  E.Nodes = G.ElemConnect(ElemNo,:);
  f(ElemNo,:) = E.Nodes(1:4);
end
patch('Vertices',v,'Faces',f,'FaceVertexCData',c,'FaceColor','interp'); 
axis off
axis equal
hold off
colorbar
