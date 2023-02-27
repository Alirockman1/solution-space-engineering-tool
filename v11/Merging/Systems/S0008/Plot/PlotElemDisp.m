% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function PlotElemDisp(G, A, CompNo)

% This function plots displacements using the patch function.
% The figure is drawn to scale and element contours are included
%
% Input:  G      : Global data
%         A      : Analysis data including A.U
%         CompNo : The DOF component to plot
%                  1: UX, 2: UY, 3: UZ, 4: ROTX, 5: ROTY

figure()

Values = zeros(G.nNodes,1);

NodeNo = 0;
for j = 1:2*G.nElemX+1
  for i = 1:2*G.nElemY+1
    NodeNo = NodeNo + 1;
    DOFNo = 5*(NodeNo-1)+CompNo;
    Values(NodeNo) = A.U(DOFNo);
  end
end

DispLabels = cellstr(['   u_x'; '   u_y'; '   u_z'; '\alpha'; ' \beta']);
MyLabel = DispLabels(CompNo);

view(0,90);
str2 = sprintf('\nMin = %0.4E,  Max = %0.4E\0',min(Values),max(Values));
if (CompNo <= 3) 
  str = strcat(MyLabel,' displacements', str2);
else
  str = strcat(MyLabel,' rotations', str2);
end
title(str);
colormap jet

v = G.X;
f = zeros(G.nElem,4);
c = Values;

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
