% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function PlotZElemStr(G, A, Name, StrCompNo, ElemNo)

% This function creates through-thickness plots of strains, stresses, strain
% energy, strain energy density and failure indices for a given element.
%
% Input:  G        : Global data
%         A        : Analysis data including A.U
%         Name     : Name of the vector to plot, i.e.
%                    'StrainXY', 'Strain12', 'StressXY', 'Stress12', 'SE',
%                    'SED', 'FIdx', or 'FIdxMode'
%         StrCompNo: The component varying from 1 to 6 for stresses and
%                    strains, e.g. 1: SX/EPSX/S11/EPS11, etc.
%         ElemNo   : The element number

figure()

% Get the FE data for this element
[E] = GetFEData(G, ElemNo, 0);
% The values to plot through-thickness
Values = zeros(2*E.Layup.nLayers,1);

% Name can be 'StrainXY', 'Strain12', 'StressXY', 'Stress12', 'SE', 'SED' or 'FIdx'.
StrainXYLabels = cellstr([' \epsilon_x'; ' \epsilon_y'; ' \epsilon_z'; '\gamma_{xy}'; '\gamma_{yz}'; '\gamma_{xz}']);
Strain12Labels = cellstr([' \epsilon_1'; ' \epsilon_2'; ' \epsilon_3'; '\gamma_{12}'; '\gamma_{23}'; '\gamma_{13}']);
StressXYLabels = cellstr([' \sigma_x'; ' \sigma_y'; ' \sigma_z'; '\tau_{xy}'; '\tau_{yz}'; '\tau_{xz}']);
Stress12Labels = cellstr([' \sigma_1'; ' \sigma_2'; ' \sigma_3'; '\tau_{12}'; '\tau_{23}'; '\tau_{13}']);
FIdxLabels = cellstr([' max strain FI'; ' max stress FI'; '    Tsai-Wu FI']); 
FIdxModeLabels = cellstr(['max strain failure mode'; 'max stress failure mode']);

switch (lower(Name))
  case 'strainxy'
    MyLabel = StrainXYLabels(StrCompNo);  
    for k = 1:E.Layup.nLayers
      Values(2*k-1) = A.StrainXY(StrCompNo,ElemNo,k,1);
      Values(2*k)   = A.StrainXY(StrCompNo,ElemNo,k,2);
    end 
  case 'strain12'
    MyLabel = Strain12Labels(StrCompNo);  
    for k = 1:E.Layup.nLayers
      Values(2*k-1) = A.Strain12(StrCompNo,ElemNo,k,1);
      Values(2*k)   = A.Strain12(StrCompNo,ElemNo,k,2);
    end 
  case 'stressxy'
    MyLabel = StressXYLabels(StrCompNo);
    for k = 1:E.Layup.nLayers
      Values(2*k-1) = A.StressXY(StrCompNo,ElemNo,k,1);
      Values(2*k)   = A.StressXY(StrCompNo,ElemNo,k,2);
    end 
  case 'stress12'
    MyLabel = Stress12Labels(StrCompNo);  
    for k = 1:E.Layup.nLayers
      Values(2*k-1) = A.Stress12(StrCompNo,ElemNo,k,1);
      Values(2*k)   = A.Stress12(StrCompNo,ElemNo,k,2);
    end 
  case 'se'
    MyLabel = ' strain energy';  
    for k = 1:E.Layup.nLayers
      Values(2*k-1) = A.SE(ElemNo,k);
      Values(2*k)   = A.SE(ElemNo,k);
    end 
  case 'sed'
    MyLabel = ' strain energy density';  
    for k = 1:E.Layup.nLayers
      Values(2*k-1) = A.SED(ElemNo,k);
      Values(2*k)   = A.SED(ElemNo,k);
    end 
  case 'fidx'
    MyLabel = FIdxLabels(StrCompNo);  
    for k = 1:E.Layup.nLayers
      Values(2*k-1) = A.FIdx(StrCompNo,ElemNo,k,1);
      Values(2*k)   = A.FIdx(StrCompNo,ElemNo,k,2);
    end 
  case 'fidxmode'
    MyLabel = FIdxModeLabels(StrCompNo);  
    for k = 1:E.Layup.nLayers
      Values(2*k-1) = A.FIdxMode(StrCompNo,ElemNo,k,1);
      Values(2*k)   = A.FIdxMode(StrCompNo,ElemNo,k,2);
    end 
  
  otherwise
   disp('PlotZElemStr has been called with an invalid label')
   return
    
end

str1 = sprintf(' values for element %i',ElemNo);
str2 = sprintf('\nMin = %0.4E,  Max = %0.4E',min(Values),max(Values));
str = strcat(MyLabel, str1, str2);

% The total thickness is denoted h, see Lund (2016) pp. 204 and 227
h = E.Layup.tTotal;
% Saving layer thicknesses as vector h_l, see Lund (2016) pp. 227
h_l = E.Layup.t(1:E.Layup.nLayers); 

% Define z-coordinate used in CLT, see Lund (2016) pp. 68
z = zeros(E.Layup.nLayers+1,1); 
% Define the z-coordinate z(1:E.Layup.nLayers+1), such that 
% z(k) = z-coordinate of the bottom of layer k
% and z(k+1)= z-coordinate of the top of layer k
z(1) = -h/2;
for k = 1:E.Layup.nLayers
  z(k+1) = z(k) + h_l(k);
end

% Define the z-coordinate z_plot(1:2*E.Layup.nLayers) used for plotting layer values
% z_plot(2*k-1) = z-coordinate of the bottom of layer k
% z_plot(2*k)   = z-coordinate of the top of layer k
z_plot = zeros(2*E.Layup.nLayers,1);
for k = 1:E.Layup.nLayers
  z_plot(2*k-1) = z(k);
  z_plot(2*k)   = z(k+1);
end

% Plot the data as function of z
set(gca,'DefaultTextFontSize',14)
hold on
plot(Values, z_plot); set(gca,'FontSize',12)
grid on
axis xy
axis on
title(str, 'FontSize', 14)
xlabel(MyLabel, 'FontSize', 14)
ylabel('z coordinate', 'FontSize', 14)
legend(MyLabel, 'FontSize',14,'AutoUpdate','off');
MyYAxis(1,1) = 0; MyYAxis(1,2) = z_plot(1);
MyYAxis(2,1) = 0; MyYAxis(2,2) = z_plot(2*E.Layup.nLayers);
line(MyYAxis(:,1),MyYAxis(:,2),'linewidth',2,'Color',[.0 .0 .0]);
hold off
