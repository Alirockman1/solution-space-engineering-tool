% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function PlotThick(G, k)

% This function plots element thickness or layer thickness using the patch function. 
% The figure is drawn to scale and element contours are included. 
%
% Input:  G        : Global data
%         k        : The layer of interest. If k = 0, then total element thickness is plotted

figure()

if (k == 0)
  str = sprintf('Element thickness');
else
  str = sprintf('Thickness of layer %i',k);
end  
title(str);
colormap jet

hold on
for ElemNo=1:G.nElem
  [E] = GetFEData(G, ElemNo, 0); 
  if (k == 0)
    ElemValues(1:4) = sum(E.Layup.t);
  else
    ElemValues(1:4) = E.Layup.t(k);
  end
  % Plot the element edges (using only corner nodes)
  x = [G.X(E.Nodes(1),1) G.X(E.Nodes(2),1) G.X(E.Nodes(3),1) G.X(E.Nodes(4),1)];
  y = [G.X(E.Nodes(1),2) G.X(E.Nodes(2),2) G.X(E.Nodes(3),2) G.X(E.Nodes(4),2)];
  patch(x,y,ElemValues)
end
colorbar
axis off
axis equal
hold off
