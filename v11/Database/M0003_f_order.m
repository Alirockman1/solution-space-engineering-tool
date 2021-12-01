%% M0003_f_order.m


%% Discription:
% This function calculates the deformation order of the two sectors of a
% car during a frontal crash.

% Input:
% F_1 = Deformation force of the first sector of the car [N]
% F_2 = Deformation force of the second sector of the car [N]

% Intermediate:

% Output:
% order = Order of the deformation of sector one and two [-]

% Example:


%% Formula:
%
% $order = F_1-F_2$
% 
function [order] = M0003_f_order(F_1,F_2)

order = F_1 - F_2;

end
