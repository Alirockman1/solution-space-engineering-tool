%% Function: Bottom-up Mapping of Problem S0012_f_cfkIter3
% Template generated automatically
% 
% Inputs:
%     - x: Design Variables - Array size: [6,sample size]
%         -- a1: Fibre direction of first ply [°] - Bounds: [-90,90]
%         -- t1: Thickness of first ply [mm] - Bounds: [0,3]
%         -- a2: Fibre direction of second ply [°] - Bounds: [-90,90]
%         -- t2: Thickness of second ply [mm] - Bounds: [0,3]
%         -- a3: Fibre direction of third ply [°] - Bounds: [-90,90]
%         -- t3: Thickness of third ply [mm] - Bounds: [0,3]
%     - param: Constant Parameters - Array size: [1,0]
% 
% Outputs:
%     - qoi: Quantities of Interest - Array size: [3,sample size]
%         -- f: Max. Deflection of the cantilever [mm] - Critical values: [-Inf,5]
%         -- t: Total Laminate Thickness [mm] - Critical values: [0,5]
%         -- xi: Deflection angle [°] - Critical values: [-5,1]

function qoi = S0012_f_cfkIter3(x,param)
    %% Initialization
    % Unwrapping inputs - design variables
%     a1 = x(1,:)';
%     t1 = x(2,:)';
%     a2 = x(3,:)';
%     t2 = x(4,:)';
%     a3 = x(5,:)';
%     t3 = x(6,:)';
    a = x';
    % Unwrapping inputs - constant parameters
    % Alocating space for output arrays
    f = nan(size(x,2),1);
    t = nan(size(x,2),1);
    xi = nan(size(x,2),1);
    
    %% Bottom-up Mapping
    prefix = '..\Merging\Systems\S0010\';
    addpath(prefix, [prefix 'FEA'],[prefix 'Opt'],[prefix 'Plot']);

    [nLayers, n] = size(x);
%     nLayers = .5*nLayers;

%     a = nan(n,nLayers);
%     T = nan(n,nLayers);
% 
%     for i=1:nLayers
%         a(:,i) = x(2*i-1,:)';
%         T(:,i) = x(2*i,:)'; 
%     end

    T = 0.2/1000; % in mm


    fprintf('\nStarting new RUN\nWith %d Iterations\n\n-------------------\n\n', n);
    tic
    parfor i=1:n
        fprintf('Calculating Iteration %d out of %d\n', i, n);
        A = cfkEval(a(i,:), T*ones(1,nLayers)); % in mm
%         A = cfkEval(a(i,:), T(i,:)/1000); % in mm
        f(i) = A.deflMax * 1000; % in mm
        t(i) = A.totalT * 1000; % in mm
        Sf(i) = A.maxFI; 
        xi(i) = A.deflAngle; % in deg
        m(i) = A.m; % in kg
    end
    
    toc
    fprintf('Finished Job\n\n----------------\n\n');
    
    %% Closing operations
    % Wrapping outputs
    qoi = nan(3, size(x,2));
    qoi(1,:) = f';
    qoi(2,:) = t';
    qoi(3,:) = xi';
end