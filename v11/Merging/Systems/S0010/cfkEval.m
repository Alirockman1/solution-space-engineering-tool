% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function A = cfkEval(alpha, t, showFig)
% tic

% if size(alpha) ~= size(t)
%     disp('Mismatched array sizes')
%     return
% end

%% All global data are stored in a struct G - Global data
G.LX = 0.5;       % Length of plate (x) is 0.5 m
G.LY = 0.05;       % Height of plate (y) is 0.1 m
G.nElemX = 30;    % Number of elements in x-direction
G.nElemY = 3;    % Number of elements in y-direction
% The following settings about patches are used when parameterizing
% the laminated plate for optimization purposes.
G.nPatchX = 1;    % Number of patches in x-direction
G.nPatchY = 1;    % Number of patches in y-direction
G.SymLayup = 0;   % Symmetric layup is not enforced

% Create the mesh
G = Mesh(G);

% Define the materials (1: steel, 2: aluminium, 3: CFRP, 4: GFRP)
G = MatProps(G);

% Define the layup using patches. If G.nPatchX = G.nPatchY = 1, then all 
% elements are associated with the same patch, i.e. the same layup
% G = DefineLayup(G, nLayers, t(1:nLayers), MatNo(1:nLayers), Angle(1:nLayers))
% If G.SymLayup = 1, then the input layers define the lower part of the
% layup and the upper layers will be mirrored.

% EXERCISES 1
% G = DefineLayup(G, 1, 0.001, 2, 0); % Ex. 1 (A)
% G = DefineLayup(G,4, [2.5e-04 2.5e-04 2.5e-04 2.5e-04], [2 2 2 2], [73,-15,19,26]); % Ex. 1 (B)
% G = DefineLayup(G, 4, [1.25e-04 1.25e-04 1.25e-04 1.25e-04], [3 3 3 3], [0 90 90 0]); % Ex. 1 (C)
% G = DefineLayup(G, 4, [1.25e-04 1.25e-04 1.25e-04 1.25e-04], [3 3 3 3], [0 90 0 90]);% Ex. 1 (D)
% G = DefineLayup(G, 4, [1.25e-04 1.25e-04 1.25e-04 1.25e-04], [3 3 3 3], [0 0 90 90]);% Ex. 1 (E)
% G = DefineLayup(G, 4, [1.25e-04 1.25e-04 1.25e-04 1.25e-04], [3 3 3 3], [45 45 45 45]); % Ex. 1 (F)
% G = DefineLayup(G, 4, [1.25e-04 1.25e-04 1.25e-04 1.25e-04], [3 3 3 3], [45 -45 -45 45]);% Ex. 1 (G)
% G = DefineLayup(G, 4, [1.25e-04 1.25e-04 1.25e-04 1.25e-04], [3 3 3 3], [45 45 -45 -45]);% Ex. 1 (H)

% EXERCISES 2
% G = DefineLayup(G, 4, [1.25e-04 1.25e-04 1.25e-04 1.25e-04], [3 3 3 3], [0 45 -45 90]);% Ex. 2 (A)
% G = DefineLayup(G, 8, [1.25e-04 1.25e-04 1.25e-04 1.25e-04 1.25e-04 1.25e-04 1.25e-04 1.25e-04], [3 3 3 3 3 3 3 3], [0 90 45 -45 -45 45 90 0]);% Ex. 2 (B)
% G = DefineLayup(G, 7, [1.25e-04 1.25e-04 1.25e-04 1.25e-04 1.25e-04 1.25e-04 1.25e-04], [3 3 3 3 3 3 3], [45 -45 90 0 90 -45 45]);% Ex. 2 (B)

% EXERCISES 3
% theta = 15;
% G = DefineLayup(G, 3, [1.25e-04  1.25e-04 1.25e-04], [3 3 3 ], [theta -theta 0]); % 4-layer quasi-isotropic CFRP

% BASIC EXAMPLES
% G = DefineLayup(G, 2, [0.001 0.001], [3 3], [0 90]); % 2-layer cross-ply CFRP
%G = DefineLayup(G, 1, [0.001], [4], [-45]);          % Single-layer GFRP
%G = DefineLayup(G, 10, [0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001], ...
%    [4 4 4 4 4 4 4 4 4 4], [-45 45 -45 45 -45 45 -45 45 -45 45]); % 10-layer angle-ply GFRP
% G = DefineLayup(G, 4, [0.0001 0.0001 0.0001 0.0001], [3 3 3 3], [0 0 0 0]); % 4-layer quasi-isotropic CFRP
G = DefineLayup(G, length(alpha), ...
    t, ...
    3*ones(1,length(alpha)), ...
    alpha);


% Define the displacement BCs. 
% [G, A] = DefineBCs(G, DispBC) 
%          where DispBC = 1 (2D cantilever), 
%                         2 (cantilever plate) 
%                         3 (clamped plate) 
%                         4 (simply supported plate)
%                         5 UX = 0 at left edge, UY = 0 at lower edge and lower left node is fixed
%                         6 Bending test (left ux, uy, uz, right only uz)
[G, A] = DefineBCs(G, 6);



% Calculating MASS (QUICK & DIRTY)
A.totalT = sum(t);
if A.totalT == 0
    % set important values to nan and return
    A.deflAngle = nan;
    A.deflMax = nan;
    A.maxFI = nan;
    return
end
totalV = G.LX * G.LY * A.totalT; % in m^3

%considering mat3 for ALL LAYERS!
A.m = 1580*totalV; % in kg

% Call AllocSolVectors that allocates the main solution vectors
[A] = AllocSolVectors(A);

% Add contributions to the load vector
% [A] = Load(G, A, LoadBC, ScaleFac) 
%       where LoadBC = 1 (point load FY at mid point of right edge)
%                      2 (point load FZ at mid point of right edge)
%                      3 (point load FZ at mid point of plate)
%                      4 (constant pressure P at plate surface)
%                      5 (constant extensional load/length N_x at right edge)
%                      6 (constant transverse load/length N_y at right edge)
%                      7 (constant extensional load/length N_y at upper edge)
%                      10 (point load FZ at top point of right edge)
%             ScaleFac is the scaling of the default unit load/pressure applied 
[A] = Load(G, A, 11, 1.0E3);

% We loop over all finite elements and assemble the stiffness matrix.
% disp('Assembling the stiffness matrix A.K');

[A] = AssembleK(G, A);

%% Define ABD-Matrices HERE
G = ABD(G, A);

% toc
% return


% disp('Solving the algebraic system of equations')
% The stiffness matrix is factored using default matrix decomposition.
% The factored matrix may then be reused in DSA.
A.KFactored = decomposition(A.K(A.FreeDOFs,A.FreeDOFs)); 
% The static equilibrium equations are solved.
A.U(A.FreeDOFs,:) = A.KFactored \ A.F(A.FreeDOFs,:);
A.U(A.FixedDOFs,:)= 0.0;

% You may also perform the assembly and solve the system of equations by
% simply calling: [A] = SolveStatic(G, A)

% Plot displacement: PlotDisp(G, A, DOFNo)
% where DOFNo = 1 (UX), 2 (UY), 3 (UZ), 4 (RX) or 5 (RY)
% PlotDisp(G, A, 1);
% PlotDisp(G, A, 2);
% PlotDisp(G, A, 3);
% PlotElemDisp(G, A, 3);
% A = PlotDispZ(G, A, 100 );
% PlotDisp(G, A, 4);
% PlotDisp(G, A, 5);
% You may also plot displacements on the FE mesh using PlotElemDisp(G, A, CompNo)

% disp('Postprocessing - computing strains, stresses, etc.');
% Compute element strains, stresses and failure indices - postprocessing
[A] = StrPostprocessing(G, A);
% disp('Finished postprocessing');

if ~exist('showFig','var')
    showFig = 0;
end

A = PlotDispZ(G, A, showFig);

% Plot element strains, stresses or failure indices using
% PlotElemStr(G, A, Name, StrCompNo, k, Pos)
% where Name is the name of the vector to plot, i.e.
%  'StrainXY', 'Strain12', 'StressXY', 'Stress12', or 'FIdx',
% StrCompNo = 1,..,6, k is the layer of interest, and
% Pos = 1 (bottom) or 2 (top)
% PlotElemStr(G, A, 'StressXY', 1, 4, 1);

% We plot all the stress components through-thickness in the last element,
% i.e. at the lower right corner.
% PlotZElemStr(G, A, Name, StrCompNo, ElemNo)
% PlotZElemStr(G, A, 'Stress12', 1, G.nElem);
% PlotZElemStr(G, A, 'Stress12', 2, G.nElem);
% PlotZElemStr(G, A, 'Stress12', 3, G.nElem);
% PlotZElemStr(G, A, 'Stress12', 4, G.nElem);
% PlotZElemStr(G, A, 'Stress12', 5, G.nElem);
% PlotZElemStr(G, A, 'Stress12', 6, G.nElem);

% PlotZElemStr(G, A, 'Strain12', 1, G.nElem);
% PlotZElemStr(G, A, 'Strain12', 2, G.nElem);
% PlotZElemStr(G, A, 'Strain12', 3, G.nElem);
% PlotZElemStr(G, A, 'Strain12', 4, G.nElem);
% PlotZElemStr(G, A, 'Strain12', 5, G.nElem);
% PlotZElemStr(G, A, 'Strain12', 6, G.nElem);

% PlotZElemStr(G, A, 'StressXY', 1, G.nElem);
% PlotZElemStr(G, A, 'StressXY', 2, G.nElem);
% PlotZElemStr(G, A, 'StressXY', 3, G.nElem);
% PlotZElemStr(G, A, 'StressXY', 4, G.nElem);
% PlotZElemStr(G, A, 'StressXY', 5, G.nElem);
% PlotZElemStr(G, A, 'StressXY', 6, G.nElem);

% PlotZElemStr(G, A, 'StrainXY', 1, G.nElem);
% PlotZElemStr(G, A, 'StrainXY', 2, G.nElem);
% PlotZElemStr(G, A, 'StrainXY', 3, G.nElem);
% PlotZElemStr(G, A, 'StrainXY', 4, G.nElem);
% PlotZElemStr(G, A, 'StrainXY', 5, G.nElem);
% PlotZElemStr(G, A, 'StrainXY', 6, G.nElem);

% PlotFEModel(G,1,0)

% PlotZElemStr(G, A, 'FIdX', 1, G.nElem);
% PlotZElemStr(G, A, 'FIdX', 2, G.nElem);
% PlotZElemStr(G, A, 'FIdX', 3, G.nElem);

% PlotZElemStr(G, A, 'FIdXMode', 1, G.nElem);
% PlotZElemStr(G, A, 'FIdXMode', 2, G.nElem);

end