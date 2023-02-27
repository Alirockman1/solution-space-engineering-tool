function A = PlotDispZ(G, A, showFig)

% This function plots z displacements 
%
% Input:  G      : Global data
%         A      : Analysis data including A.U

if showFig==1
    figure()
end

Disp = zeros(G.nElemY,G.nElemX);

CompNo = 3;

NodeNo = 0;
for j = 1:2*G.nElemX+1
  for i = 1:2*G.nElemY+1
    NodeNo = NodeNo + 1;
    DOFNo = 5*(NodeNo-1)+CompNo;
    Disp(i,j) = A.U(DOFNo);
  end
end

DispLabels = cellstr(['   u_x'; '   u_y'; '   u_z'; '\alpha'; ' \beta']);
MyLabel = DispLabels(CompNo);

% view(0,90);

% deflMidTop = Disp(1,G.nElemX+1);
% deflMidBottom = Disp(2*G.nElemY+1,G.nElemX+1);

midDisp = Disp(1:2*G.nElemY+1,G.nElemX+1);
% gradMidDispy = gradient(midDisp);

% showDisp = Disp - midDisp + midDisp(G.nElemY+1);

A.showDisp = Disp - midDisp;
A.showDisp = A.showDisp - max(A.showDisp(:,end));

deflTop = A.showDisp(1,2*G.nElemX+1);
deflBottom = A.showDisp(2*G.nElemY+1,2*G.nElemX+1);

deflDelta = deflTop - deflBottom;
A.deflAngle = 2*asind(deflDelta/(2*G.LY));

% [~, gradDispy] = gradient(Disp);
% maxGrad = max(abs(gradDispy), [], 'all')* G.nElemY;
% 
% A.deflAngle = atand(maxGrad / G.LY);

if ~isreal(A.deflAngle)
    A.deflAngle = inf;
end

A.deflMax = max(A.showDisp,[],'all');

A.maxFI = max(A.FIdx(3,:,:,:), [], 'all');




if showFig==1

    str2 = sprintf('\nMax Disp = %0.3G mm\0',1000*max(max(A.showDisp)));
    if (CompNo <= 3) 
        str = strcat(MyLabel,' displacements', str2);
    else
        str = strcat(MyLabel,' rotations', str2);
    end

    str3 = sprintf('\nmax Angle = %0.3G°, maxFI = %0.2G \0', A.deflAngle, A.maxFI);
    title(strcat(str, str3));
    colormap jet


    hold on
%     surf(G.XPlot, G.YPlot, -Disp)
    surf(G.XPlot, G.YPlot, -A.showDisp)
    surf(G.XPlot, G.YPlot, zeros(2*G.nElemY+1,2*G.nElemX+1), 'FaceAlpha',.5)
%     surf(G.XPlot, G.YPlot, -gradDispy)
    plot3([G.LX, G.LX], [G.LY,0],[-deflTop, -deflBottom], 'LineWidth', 3, 'Color', 'red')
    hold off

    grid on

    daspect([1 1 1])
    view(75,15)
% view(0,0)


% axis([-inf inf -inf inf -minZ 0])
end

