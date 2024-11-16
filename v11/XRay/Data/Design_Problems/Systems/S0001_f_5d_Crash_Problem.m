%% S0001_f_5d_Crash_Problem.m


%% Discription:

% Input:
% F_2 = Deformation force of the second sector of the car [N]
% m = Mass of the car [kg]
% F_1 = Deformation force of the first sector of the car [N]
% v_0 = Initial speed of the car bevore the crash [m/s]
% d_1c = Deformation length of the first sector [m]
% d_2c = Deformation length of the second sector [m]

% Intermediate:

% Output:
% E_rem = Remaining energy after the crash [J]
% a_max = Maximal negative acceleration occuring while the crash [m/s^2]
% order = Order of the deformation of sector one and two [-]

% Example:


%% Formula:


%% Code:
function [E_rem,a_max,order] = S0001_f_5d_Crash_Problem (F_2,m,F_1,v_0,d_1c,d_2c)
	[a_max] = M0001_f_acceleration(F_2,m);
	[E_rem] = M0002_f_remaining_energy(F_1,F_2,m,v_0,d_1c,d_2c);
	[order] = M0003_f_order(F_1,F_2);
end