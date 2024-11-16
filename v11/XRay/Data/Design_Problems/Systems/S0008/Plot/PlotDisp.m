% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function Disp = PlotDisp(G, A, CompNo)

% This function plots displacements using the contourf function.
%
% Input:  G      : Global data
%         A      : Analysis data including A.U
%         CompNo : The DOF component to plot
%                  1: UX, 2: UY, 3: UZ, 4: ROTX, 5: ROTY

% figure()

Disp = zeros(G.nElemY,G.nElemX);

NodeNo = 0;
for j = 1:2*G.nElemX+1
  for i = 1:2*G.nElemY+1
    NodeNo = NodeNo + 1;
    DOFNo = 5*(NodeNo-1)+CompNo;
    Disp(i,j) = A.U(DOFNo);
  end
end

% DispLabels = cellstr(['   u_x'; '   u_y'; '   u_z'; '\alpha'; ' \beta']);
% MyLabel = DispLabels(CompNo);
% 
% view(0,90);
% str2 = sprintf('\nMin = %0.4E,  Max = %0.4E\0',min(min(Disp)),max(max(Disp)));
% if (CompNo <= 3) 
%   str = strcat(MyLabel,' displacements', str2);
% else
%   str = strcat(MyLabel,' rotations', str2);
% end
% title(str);
% colormap jet
% 
% % 2D contour plot of DOF:
% 
% contourf(G.XPlot, G.YPlot, Disp, 15); colormap jet; colorbar; 
% title(str)
% axis off
% axis equal
