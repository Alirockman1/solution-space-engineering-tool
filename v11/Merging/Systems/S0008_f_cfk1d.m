%% Function: Bottom-up Mapping of Problem S0008_f_cfk1d
% Template generated automatically
% 
% Inputs:
%     - x: Design Variables - Array size: [2,sample size]
%         -- a1: Fibre direction of the first layer [°] - Bounds: [-90,90]
%         -- a2: Fibre direction of the second layer [°] - Bounds: [-90,90]
%     - param: Constant Parameters - Array size: [1,0]
% 
% Outputs:
%     - qoi: Quantities of Interest - Array size: [2,sample size]
%         -- f: Max. Deflection of the rod [mm] - Critical values: [-Inf,5]
%         -- Sf: Security factor for failure [] - Critical values: [-Inf,0.5]

function qoi = S0008_f_cfk1d(x,param)
    %% Initialization
    % Unwrapping inputs - design variables
    a1 = x(1,:)';
    a2 = x(2,:)';
    % Unwrapping inputs - constant parameters
    % Alocating space for output arrays
    f = nan(size(x,2),1);
    Sf = nan(size(x,2),1);

    
    %% Bottom-up Mapping
    prefix = '..\Merging\Systems\S0008\';
    addpath(prefix, [prefix 'FEA'],[prefix 'Opt'],[prefix 'Plot']);

    n = size(x,2);
    for i=1:n
        A = cfkEval([a1(i), a2(i)]);
        f(i) = A.maxDisp * 1000;
        Sf(i) = A.Sf;
    end

%     f = rand(size(x,2),1) .* 7;

%     Sf = zeros(size(x,2),1);
    %% Closing operations
    % Wrapping outputs
    qoi = nan(2, size(x,2));
    qoi(1,:) = f';
    qoi(2,:) = Sf';
end