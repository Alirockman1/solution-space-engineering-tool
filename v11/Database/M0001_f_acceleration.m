%% M0001_f_acceleration.m


%% Discription:
% This function calculates the maximal negative acceleration of a frontal car crash
% depending on the mass of the car and the force the passive safety
% structure provides to stop the car.

% Input:
% F_2 = Deformation force of the second sector of the car [N]
% m = Mass of the car [kg]

% Intermediate:

% Output:
% a_max = Maximal negative acceleration occuring while the crash [m/s^2]

% Example:


%% Formula:
%
% $a_{max} = \frac{F_2}{m}$
% 
function [a_max] = M0001_f_acceleration(F_2,m)

a_max = F_2 ./ m;

end
