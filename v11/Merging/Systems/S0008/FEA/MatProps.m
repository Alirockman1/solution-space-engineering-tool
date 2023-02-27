% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [G]  = MatProps(G)
% The function MatProps defines the  material properties

% We define four materials:
%  G.Mat(1): steel
%  G.Mat(2): aluminum
%  G.Mat(3): CFRP - carbon-epoxy (AS/3501)
%  G.Mat(4): E-glass-epoxy

% Material 1: steel
G.Mat(1).E1   = 210E9;
G.Mat(1).E2   = G.Mat(1).E1;
G.Mat(1).nu12 = 0.3;
G.Mat(1).G12  = G.Mat(1).E1 / (2*(1+G.Mat(1).nu12));
G.Mat(1).G13  = G.Mat(1).G12;
G.Mat(1).G23  = G.Mat(1).G12;
G.Mat(1).nu21 = G.Mat(1).nu12;
G.Mat(1).rho  = 7800;

% Material 2: aluminum - from Reddy (2004, pp. 88)
G.Mat(2).E1   = 73.1E9;
G.Mat(2).E2   = G.Mat(2).E1;
G.Mat(2).nu12 = 0.33;
G.Mat(2).G12  = G.Mat(2).E1 / (2*(1+G.Mat(2).nu12));
G.Mat(2).G13  = G.Mat(2).G12;
G.Mat(2).G23  = G.Mat(2).G12;
G.Mat(2).rho  = 2700;
G.Mat(2).nu21 = G.Mat(2).nu12;

% Material 3: Carbon-epoxy (AS/3501) - from Reddy (2004, pp. 88)
G.Mat(3).E1   = 137.9E9;
G.Mat(3).E2   = 9.0E9;
G.Mat(3).nu12 = 0.3;
G.Mat(3).G12  = 7.1E9;
G.Mat(3).G13  = 7.1E9;
G.Mat(3).G23  = 6.2E9;
G.Mat(3).rho  = 1580;
G.Mat(3).nu21 = G.Mat(3).E2/G.Mat(3).E1*G.Mat(3).nu12;

% ADDED THE FAILURE CRITERIA
G.Mat(3).Xt       = 1950e6;
G.Mat(3).Xc       = 1500e6;
G.Mat(3).Yt       = 50e6;
G.Mat(3).Yc       = 200e6;
G.Mat(3).S        = 80e6;
G.Mat(3).eps1t    = 1.4e-2;
G.Mat(3).eps1c    = 1.18e-2;
G.Mat(3).eps2t    = .44e-2;
G.Mat(3).eps2c    = 2e-2;
G.Mat(3).gamma12u = 2e-2;

% Material 4: E-glass-epoxy
G.Mat(4).E1   = 34.0E9;
G.Mat(4).E2   = 8.2E9;
G.Mat(4).nu12 = 0.29;
G.Mat(4).G12  = 4.5E9;
G.Mat(4).G13  = 4.5E9;
G.Mat(4).G23  = 4.0E9;
G.Mat(4).rho  = 1910;
G.Mat(4).nu21 = G.Mat(4).E2/G.Mat(4).E1*G.Mat(4).nu12;

% Strength parameters can also be added to G.Mat
