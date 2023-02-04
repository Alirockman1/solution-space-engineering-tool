% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [TMat] = InplaneRotationTMat(Angle)

% This function sets up the tranformation TMat from material 
% directions to element (ESYS) directions, see Lund (2022) p. 216-217

TMat = zeros(6,6);
a = cosd(Angle);
b = sind(Angle);

% Jones def of angle
TMat(1,1) = a^2;
TMat(2,1) = b^2;
TMat(4,1) = -a*b;
TMat(1,2) = b^2;
TMat(2,2) = TMat(1,1);
TMat(4,2) = -TMat(4,1);
TMat(3,3) = 1;
TMat(1,4) = 2*a*b;
TMat(2,4) = -TMat(1,4);
TMat(4,4) = a^2-b^2;
TMat(5,5) = a;
TMat(6,5) = b;
TMat(5,6) = -TMat(6,5);
TMat(6,6) = TMat(5,5);

  % Cook def of angle
% TMat(1,1) = a^2;
% TMat(2,1) = b^2;
% TMat(4,1) = -2*a*b;
% TMat(1,2) = b^2;
% TMat(2,2) = TMat(1,1);
% TMat(4,2) = -TMat(4,1);
% TMat(3,3) = 1;
% TMat(1,4) = a*b;
% TMat(2,4) = -TMat(1,4);
% TMat(4,4) = a^2-b^2;
% TMat(5,5) = a;
% TMat(6,5) = b;
% TMat(5,6) = -TMat(6,5);
% TMat(6,6) = TMat(5,5);

 