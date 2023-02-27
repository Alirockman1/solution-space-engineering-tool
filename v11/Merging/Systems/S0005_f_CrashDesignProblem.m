%% Function: Bottom-up Mapping of Problem S0005_f_CrashDesignProblem
% Template generated automatically
% 
% Inputs:
%     - x: Design Variables - Array size: [6,sample size]
%         -- F_2: Force applied during the second stage of the crash [N] - Bounds: [0,1e+06]
%         -- m: Total mass of the vehicle [kg] - Bounds: [1500,2500]
%         -- F_1: Force applied during the first stage of the crash [N] - Bounds: [0,1e+06]
%         -- v_0: Vehicle speed at the start of the crash [m/s] - Bounds: [0,100]
%         -- d1c: Critical displacement during the first stage of crash [m] - Bounds: [0,0.6]
%         -- d2c: Critical displacement during the second stage of crash [m] - Bounds: [0,0.6]
%     - param: Constant Parameters - Array size: [1,0]
% 
% Outputs:
%     - qoi: Quantities of Interest - Array size: [3,sample size]
%         -- E_rem: Energy remaining at the end of the crash [J] - Critical values: [-Inf,0]
%         -- a_max: Maximum acceleration during crash [m/s^2] - Critical values: [0,320]
%         -- order: Order of deformantion [] - Critical values: [-Inf,0]

function qoi = S0005_f_CrashDesignProblem(x,param)
    %% Initialization
    % Unwrapping inputs - design variables
    F_2 = x(1,:)';
    m = x(2,:)';
    F_1 = x(3,:)';
    v_0 = x(4,:)';
    d1c = x(5,:)';
    d2c = x(6,:)';
    % Unwrapping inputs - constant parameters
    % Alocating space for output arrays
    E_rem = nan(size(x,2),1);
    a_max = nan(size(x,2),1);
    order = nan(size(x,2),1);
    
    %% Bottom-up Mapping
    E_rem = 1/2.*m.*v_0.^2 - (F_1.*d1c + F_2.*d2c);
    a_max = F_2./m;
    order = F_1 - F_2;
    
    %% Closing operations
    % Wrapping outputs
    qoi = nan(3, size(x,2));
    qoi(1,:) = E_rem';
    qoi(2,:) = a_max';
    qoi(3,:) = order';
end