% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function PlotElemVec(G, ElemVec)

% This function plots an element vector using the patch function. 
% The figure is drawn to scale and element contours are included. 
%
% Input:  G      : Global data
%         ElemVec: The vector containing element values

figure()
title('Element values');
colormap jet

v = G.X;
f = zeros(G.nElem,4);
c = zeros(G.nElem,1);

hold on
for ElemNo=1:G.nElem
  E.Nodes = G.ElemConnect(ElemNo,:);
  f(ElemNo,:) = E.Nodes(1:4);
  c(ElemNo) = ElemVec(ElemNo);
end
patch('Vertices',v,'Faces',f,'FaceVertexCData',c,'FaceColor','flat'); 
axis off
axis equal
hold off
colorbar
