% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function PlotAngles(G, k)

figure()

str = sprintf('Material directions for layer %i',k);
title(str);
      
hold on
Scaling = 1/4*min(G.ElemLX,G.ElemLY);
for ElemNo=1:G.nElem
  E.Nodes = G.ElemConnect(ElemNo,:);
  % Plot the element edges (using only corner nodes)
  x = [G.X(E.Nodes(1),1) G.X(E.Nodes(2),1) G.X(E.Nodes(3),1) G.X(E.Nodes(4),1)];
  y = [G.X(E.Nodes(1),2) G.X(E.Nodes(2),2) G.X(E.Nodes(3),2) G.X(E.Nodes(4),2)];
  fill(x,y,'w')
  PatchNo = G.PatchNo(ElemNo);
  Angle = G.Layup(PatchNo).Angle(k); % The fiber angle
  % Compute the coordinates of the center point Pcg
  Pcg(1) = sum(x)/4;
  Pcg(2) = sum(y)/4;
  % Compute the two points defining the line representing the direction
  wv = [cosd(Angle); sind(Angle)]'*Scaling;
  Pv1 = Pcg - wv;
  Pv2 = Pcg + wv;
  plot([Pv1(1),Pv2(1)],[Pv1(2),Pv2(2)],'r-') 
end
axis off
axis equal
hold off
