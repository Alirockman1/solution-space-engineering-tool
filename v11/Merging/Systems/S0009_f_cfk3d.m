%% Function: Bottom-up Mapping of Problem S0009_f_cfk3d
% Template generated automatically
% 
% Inputs:
%     - x: Design Variables - Array size: [3,sample size]
%         -- a1: Fibre direction of the first layer [°] - Bounds: [-90,90]
%         -- a2: Fibre direction of the second layer [°] - Bounds: [-90,90]
%         -- a3: Fibre direction of the third layer [°] - Bounds: [-90,90]
%     - param: Constant Parameters - Array size: [1,0]
% 
% Outputs:
%     - qoi: Quantities of Interest - Array size: [2,sample size]
%         -- f: Max. Deflection of the rod [mm] - Critical values: [-Inf,5]
%         -- Sf: Security factor for failure [] - Critical values: [-Inf,0.5]

function qoi = S0009_f_cfk3d(x,param)
    %% Initialization
    % Unwrapping inputs - design variables
    a1 = x(1,:)';
    a2 = x(2,:)';
    a3 = x(3,:)';
    % Unwrapping inputs - constant parameters
    % Alocating space for output arrays
    f = nan(size(x,2),1);
    Sf = nan(size(x,2),1);
    
    %% Bottom-up Mapping
    prefix = '..\Merging\Systems\S0008\';
    addpath(prefix, [prefix 'FEA'],[prefix 'Opt'],[prefix 'Plot']);

    n = size(x,2);
    for i=1:n
        disp(['RUN ' num2str(i)])
        
        % rotating input in 90 deg
        xxx = mod([a1(i), a2(i), a3(i)],180)-90;
        A = cfkEval(xxx);
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