%% S0002_f_BeamDisplacement_Problem.m


%% Discription:

% Input:


% Intermediate:

% Output:

% Example:


%% Formula:


%% Code:
function [u] = S0002_f_BeamDisplacement_Problem (I1,l1,E1,I2,l2,E2)
    u = nan(size(I1));
    for i=1:size(I1,2)
        % Generate stiffness matrix of both beam components
        K1 = generateBeamStiffnessMatrix([I1(i),l1(i),E1(i)]);
        K2 = generateBeamStiffnessMatrix([I2(i),l2(i),E2(i)]);

        % Check Entries
        flag1 = check_EligibilityAsStiffnessMatrix(K1);
        flag2 = check_EligibilityAsStiffnessMatrix(K2);
        if(~flag1)
            u = inf;
            return
        end
        if(~flag2)
            u = inf;
            return
        end

        F = 1;

        % First step: build global K
        global_K = zeros(6,6);
        global_K(1:4,1:4) = global_K(1:4,1:4) + K1;
        global_K(3:6,3:6) = global_K(3:6,3:6) + K2;
        global_K_r = global_K(3:6,3:6); % no displacement/angle at the left, creating reduced matrix form

        % Build (Reduced) Global Force
        global_F_r = [0;0;-F;0];

        % (Reduced) Global Displacement: F=K*u -> u = F\K
        global_u_r = global_K_r\global_F_r;
        u(i) = -global_u_r(3); % main quantity of interest is displacement on the tip
    end
end


function K = generateBeamStiffnessMatrix(DVs)
    I   = DVs(1); % [m^4] moment of inertia
    l   = DVs(2); % [m] length
    E   = DVs(3); % [Pa] young's modulus
    
    k = [12 , 6*l , -12 ,  4*l^2, -6*l , 2*l^2]; % basic stiffness values
    K = E*I/l^3*...
        [k(1) k(2) k(3) k(2)
         k(2) k(4) k(5) k(6)
         k(3) k(5) k(1) k(5)
         k(2) k(6) k(5) k(4)]; % stiffness matrix
                                % rows: displ1, theta1, displ2, theta2
end

function elig = check_EligibilityAsStiffnessMatrix(K)
    % must be symmetric
    check_symmetry = issymmetric(K);
    
    % must be semi-positive definite
    ev = eig(K);
    epslon = 1e-10; % give some margin of error for >=0
    check_semiposdef = all(ev >= -epslon); 
    
    elig = check_symmetry & check_semiposdef;
end