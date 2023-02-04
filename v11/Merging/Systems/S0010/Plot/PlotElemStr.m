% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function PlotElemStr(G, A, Name, StrCompNo, k, Pos)

% This function plots element strains, stresses, strain energy, strain 
% energy density and failure indices using the patch function. 
% The figure is drawn to scale and element contours are included. 
%
% Input:  G        : Global data
%         A        : Analysis data containing the data to plot
%         Name     : Name of the vector to plot, i.e.
%                    'StrainXY', 'Strain12', 'StressXY', 'Stress12', 'SE',
%                    'SED', 'FIdx', or 'FIdxMode'
%         StrCompNo: The component varying from 1 to 6 for stresses and
%                    strains, e.g. 1: SX/EPSX/S11/EPS11, etc.
%         k        : The layer of interest
%         Pos      : 1 (bottom) or 2 (top) of layer

figure()

% Name can be 'StrainXY', 'Strain12', 'StressXY', 'Stress12', 'SE', 'SED' or 'FIdx'.

StrainXYLabels = cellstr([' \epsilon_x'; ' \epsilon_y'; ' \epsilon_z'; '\gamma_{xy}'; '\gamma_{yz}'; '\gamma_{xz}']);
Strain12Labels = cellstr([' \epsilon_1'; ' \epsilon_2'; ' \epsilon_3'; '\gamma_{12}'; '\gamma_{23}'; '\gamma_{13}']);
StressXYLabels = cellstr([' \sigma_x'; ' \sigma_y'; ' \sigma_z'; '\tau_{xy}'; '\tau_{yz}'; '\tau_{xz}']);
Stress12Labels = cellstr([' \sigma_1'; ' \sigma_2'; ' \sigma_3'; '\tau_{12}'; '\tau_{23}'; '\tau_{13}']);
FIdxLabels = cellstr([' max strain FI'; ' max stress FI'; '    Tsai-Wu FI']); 
FIdxModeLabels = cellstr(['max strain failure mode'; 'max stress failure mode']);
PositionLabel  = cellstr([' bottom'; '    top']);
PosLabel = PositionLabel(Pos);
LayerLabel = sprintf(' of layer %i',k);

DataWithPosLabel = 1;
switch (lower(Name))
  case 'strainxy'
    MyLabel = StrainXYLabels(StrCompNo);  
    Values = A.StrainXY(StrCompNo,:,k,Pos);
  case 'strain12'
    MyLabel = Strain12Labels(StrCompNo);  
    Values = A.Strain12(StrCompNo,:,k,Pos);
  case 'stressxy'
    MyLabel = StressXYLabels(StrCompNo);  
    Values = A.StressXY(StrCompNo,:,k,Pos);
  case 'stress12'
    MyLabel = Stress12Labels(StrCompNo);  
    Values = A.Stress12(StrCompNo,:,k,Pos);
  case 'se'
    MyLabel = ' strain energy';  
    Values = A.SE(:,k);
    DataWithPosLabel = 0;
  case 'sed'
    MyLabel = ' strain energy density';  
    Values = A.SED(:,k);
    DataWithPosLabel = 0;
  case 'fidx'
    MyLabel = FIdxLabels(StrCompNo);  
    Values = A.FIdx(StrCompNo,:,k,Pos);
  case 'fidxmode'
    MyLabel = FIdxModeLabels(StrCompNo);  
    Values = A.FIdxMode(StrCompNo,:,k,Pos);
  
  otherwise
   disp('PlotElemStr has been called with an invalid label')
   return
    
end

view(0,90);
str2 = sprintf('\nMin = %0.4E,  Max = %0.4E',min(Values),max(Values));
if (DataWithPosLabel > 0)
  str = strcat('Element ', MyLabel,' at ', PosLabel, LayerLabel, str2);
else
  str = strcat('Element ', MyLabel, LayerLabel, str2);
end
title(str);
colormap jet

v = G.X;
f = zeros(G.nElem,4);
c = zeros(G.nElem,1);

hold on
for ElemNo=1:G.nElem
  E.Nodes = G.ElemConnect(ElemNo,:);
  f(ElemNo,:) = E.Nodes(1:4);
  c(ElemNo) = Values(ElemNo);
end
patch('Vertices',v,'Faces',f,'FaceVertexCData',c,'FaceColor','flat'); 
axis off
axis equal
hold off
colorbar

