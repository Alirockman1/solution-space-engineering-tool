%% Function: Bottom-up Mapping of Problem S0010_f_cfkIter1
% Template generated automatically
% 
% Inputs:
%     - x: Design Variables - Array size: [2,sample size]
%         -- a1: Fibre direction of the first layer [°] - Bounds: [-90,90]
%         -- t1: Fibre direction of the second layer [mm] - Bounds: [0,1]
%     - param: Constant Parameters - Array size: [1,0]
% 
% Outputs:
%     - qoi: Quantities of Interest - Array size: [3,sample size]
%         -- f: Max. Deflection of the cantilever [mm] - Critical values: [-Inf,5]
%         -- Sf: Security factor for failure [] - Critical values: [-Inf,0.5]
%         -- xi: Deflection angle [°] - Critical values: [-5,1]

function qoi = S0010_f_cfkIter1(x,param)
    %% Initialization
    % Unwrapping inputs - design variables
    a1 = x(1,:)';
    t1 = x(2,:)';
    % Unwrapping inputs - constant parameters
    % Alocating space for output arrays
    f = nan(size(x,2),1);
    t = nan(size(x,2),1);
    Sf = nan(size(x,2),1);
    xi = nan(size(x,2),1);

    m = nan(size(x,2),1);
    
    %% Bottom-up Mapping
    prefix = '..\Merging\Systems\S0010\';
    addpath(prefix, [prefix 'FEA'],[prefix 'Opt'],[prefix 'Plot']);

    n = size(x,2);
    
    fprintf('\nStarting new RUN\nWith %d Iterations\n\n-------------------\n\n', n);
    tic
    for i=1:n
        fprintf('Calculating Iteration %d out of %d\n', i, n);
        A = cfkEval(a1(i), t1(i)/1000); % in mm
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

    % write additional saving option?


end