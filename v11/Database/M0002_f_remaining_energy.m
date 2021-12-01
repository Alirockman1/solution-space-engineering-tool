%% M0002_f_remaining_energy.m


%% Discription:
% This function calculates the remaining energy of a car after a frontal
% crash.

% Input:
% F_1 = Deformation force of the first sector of the car [N]
% F_2 = Deformation force of the second sector of the car [N]
% m = Mass of the car [kg]
% v_0 = Initial speed of the car bevore the crash [m/s]
% d_1c = Deformation length of the first sector [m]
% d_2c = Deformation length of the second sector [m]

% Intermediate:

% Output:
% E_rem = Remaining energy after the crash [J]

% Example:


%% Formula:
%
% $E_{rem} = \frac{m}{2}v_0^2 - (F_1 d_{1c} + F_2 d_{2c})$
% 
function [E_rem] = M0002_f_remaining_energy(F_1,F_2,m,v_0,d_1c,d_2c)

E_rem = m./2 .* v_0.^2 - (F_1.*d_1c + F_2.*d_2c);

end
