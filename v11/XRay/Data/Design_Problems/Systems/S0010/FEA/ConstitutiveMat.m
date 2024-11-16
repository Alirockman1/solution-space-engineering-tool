% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [CLoc] = ConstitutiveMat(E, k)

% Compute the constitutive matrix of layer k, see Lund (2022) p. 215
% Get material number and fiber angle
MatNo = E.Layup.MatNo(k);
Angle = E.Layup.Angle(k);

% Use 5/6 as shear correction factor
ShearCorFactor = 5/6;

C = zeros(6,6);
C(1,1) = E.Mat(MatNo).E1/(1-E.Mat(MatNo).nu12*E.Mat(MatNo).nu21);
C(1,2) = E.Mat(MatNo).nu12*E.Mat(MatNo).E2/(1-E.Mat(MatNo).nu12*E.Mat(MatNo).nu21);
C(2,1) = C(1,2);
C(2,2) = E.Mat(MatNo).E2/(1-E.Mat(MatNo).nu12*E.Mat(MatNo).nu21);
C(4,4) = E.Mat(MatNo).G12;
C(5,5) = E.Mat(MatNo).G23*ShearCorFactor;
C(6,6) = E.Mat(MatNo).G13*ShearCorFactor;

% Compute the inplane transformation matrix TMat which is the
% tranformation from material directions to local directions (ESYS)
% The angle is positive counter-clockwise from material 1-axis to 
% element d_1-axis, see Lund (2022) p. 216-217
[TMat] = InplaneRotationTMat(Angle);

% Transform the constitutive matrix to the element coordinate system
% For a plate structure we generate the mesh, such that the element coordinate 
% system is equal to the global coordinate system
% If Cook definition of angle theta, then CLoc = TMat'*C*TMat;
% We use Jones' definition of angle theta, then CLoc = inv(TMat)*C*(invTMat')
% We invert the TMat and call it InvTMat
InvTMat = inv(TMat);
CLoc = InvTMat*C*InvTMat';

