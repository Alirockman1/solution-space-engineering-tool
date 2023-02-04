% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [E] = ElemStress(E)

% This function determines the element strains and stresses for a 9-node 
% isoparametric shell element used as plate element. Thus, simplifications 
% related to node directors V1, V2 and V3 are used.
%
% Input:  E      : Element data
%
% Output: E.StrainXY(CompNo,k,Pos) where  CompNo = 1,..,6, k is layer number,
%         E.StressXY(CompNo,k,Pos) and Pos = 1,2 (bottom/top)
%         E.Strain12(CompNo,k,Pos) - this is your job :-)
%         E.Stress12(CompNo,k,Pos) - this is your job :-)
%         E.SE(k)  - strain energy computed per layer
%         E.SED(k) - strain energy density computed per layer
%         E.FIdx(CompNo,k,Pos)     - this is your job :-)
%         E.FIdxMode(CompNo,k,Pos) - this is your job :-)

%
% Documentation: Erik Lund (2022): Analysis of Composite Structures,
% Lecture notes for Ph.D. course on "Analysis and Gradient Based Optimization of
% Laminated Composite Structures", Aalborg University, May 2-6, 2022.
% See also Cook et al (2002): Concepts and Applications of Finite Element
% Analysis, 4th ed. John Wiley, ch. 16.5

% Compute the stresses at the inplane superconvergent points, i.e.
% at the 2 x 2 = 4 inplane Gauss Points, see Cook et al (2002) pp. 212
% or Lund (2022) pp. 264.
nGPInplane = 4;
GVal=1.0/sqrt(3); 
GaussCoordsInplane = [-GVal -GVal; -GVal GVal; GVal -GVal; GVal GVal];

% Number of Gauss points in thickness direction in each layer is also 2
nGPThick = 2;
GaussCoordsThick = [-GVal GVal];

% Initialize array CLayerLoc containing all layer constitutive matrices
CLayerLoc = zeros(6,6,E.Layup.nLayers);

% Loop through layers and compute constitutive matrices transformed to the
% element coordinate system
for k = 1:E.Layup.nLayers
  [CLoc] = ConstitutiveMat(E, k);
  CLayerLoc(:,:,k) = CLoc;
end

% The total thickness is denoted h, Lund (2022) pp. 204 and 227
h = E.Layup.tTotal;

% Saving layer thicknesses as vector h_l, see Lund (2022) pp. 227
h_l = E.Layup.t(1:E.Layup.nLayers); 

% Determine natural thickness coordinates (from -1 to 1), 
% see Lund (2022) pp. 227
t_Coor = zeros(E.Layup.nLayers, nGPThick);
hTop = 0.;
for k = 1:E.Layup.nLayers
  hTop = hTop + h_l(k);
  t_Coor(k,1) = -1+1/h*(2*hTop-h_l(k)*(1-GaussCoordsThick(1)));
  t_Coor(k,2) = -1+1/h*(2*hTop-h_l(k)*(1-GaussCoordsThick(2)));
end

% The node directors V1, V2 and V3, Lund (2022) pp. 204 - 207, are just 
% defined explicitly for a plate model. The general computation of these 
% can be found in the general implementation in ElemK_Shell.m.
% Here we just define them as constant vectors.
V1 = [1 0 0]; % V1 = i
V2 = [0 1 0]; % V2 = j
V3 = [0 0 1]; % V3 = k

% ___________________Begin stress/strain calculations____________________

% Matrix that pairs displacement derivatives for strain calculation, see
% Lund (2022) pp. 223 or Cook et al (2002) pp. 580
H = [1 0 0 0 0 0 0 0 0;
     0 0 0 0 1 0 0 0 0;
     0 0 0 0 0 0 0 0 1;
     0 1 0 1 0 0 0 0 0;
     0 0 0 0 0 1 0 1 0;
     0 0 1 0 0 0 1 0 0];
% O is a 3x3 matrix of zeros
O = zeros(3,3);

% Initialize stress/strain element vectors
E.StrainXY = zeros(6,E.Layup.nLayers,2);
E.StressXY = zeros(6,E.Layup.nLayers,2);
E.Strain12 = zeros(6,E.Layup.nLayers,2);
E.Stress12 = zeros(6,E.Layup.nLayers,2);
E.SE = zeros(E.Layup.nLayers,1);
E.SED = zeros(E.Layup.nLayers,1);
E.FIdx = zeros(3,E.Layup.nLayers,2); % Allocate for 3 failure indices
E.FIdxMode = zeros(2,E.Layup.nLayers,2); % Allocate for failure modes for max strain/stress criteria

% The Gauss point strains are stored in GPStrain
GPStrain = zeros(6,nGPInplane,nGPThick);
% The inplane averaged Gauss point strains are stored in EGPStrain
%EGPStrain = zeros(6,2);

% Loop through layers
for k = 1:E.Layup.nLayers

  % Loop over Gauss points in thickness direction, t
  for iGPt = 1:nGPThick % GP LOOP thickness 
    t = t_Coor(k,iGPt);
    
    %Loop over Gauss points in-plane
    for nGP = 1:nGPInplane %GP LOOP in-plane 
      r = GaussCoordsInplane(nGP,1);
      s = GaussCoordsInplane(nGP,2);
   
      % Get shape functions of the 9 node element
      [N] = ShapeFunc9(r, s);
      % Get derivatives of shape functions wrt r and s
      [dNidr, dNids] = ShapeFunc9Deriv(r, s);

      % Initialize entries in Jacobian matrix, see Lund (2022) pp. 221
      dxdr = 0.; dydr = 0.; dzdr = 0.;
      dxds = 0.; dyds = 0.; dzds = 0.;
      dxdt = 0.; dydt = 0.; dzdt = 0.;
      % Allocate and initialize Q
      Q = zeros(9,5,E.nNodes);
      
      for i = 1:E.nNodes % Loop over nodes to interpolate
        % Components of the Jacobian matrix (recursive summation, 
        % see Lund (2022) pp. 221 or Cook et al (2002) Eq. 16.5-4)
        % Here V3 is just a constant vector, i.e. not defined nodewise
        dxdr = dxdr + dNidr(i)*(E.X(i,1)+0.5*t*h*V3(1));
        dydr = dydr + dNidr(i)*(E.X(i,2)+0.5*t*h*V3(2));
        dzdr = dzdr + dNidr(i)*(E.X(i,3)+0.5*t*h*V3(3));
        dxds = dxds + dNids(i)*(E.X(i,1)+0.5*t*h*V3(1));
        dyds = dyds + dNids(i)*(E.X(i,2)+0.5*t*h*V3(2));
        dzds = dzds + dNids(i)*(E.X(i,3)+0.5*t*h*V3(3));
        dxdt = dxdt + N(i)*0.5*h*V3(1);
        dydt = dydt + N(i)*0.5*h*V3(2);
        dzdt = dzdt + N(i)*0.5*h*V3(3);

        % Components of shape function derivatives wrt. natural coordinates, 
        % see Lund (2022) pp. 224 or Cook et al (2002) Eq. 16.5-9
        % Here V1, V2 and V3 are just constant vectors, i.e. not defined nodewise
        Q(1:9,1:5,i) = [dNidr(i)   0        0      -0.5*t*h*dNidr(i)*V2(1) 0.5*t*h*dNidr(i)*V1(1);
                        dNids(i)   0        0      -0.5*t*h*dNids(i)*V2(1) 0.5*t*h*dNids(i)*V1(1);
                        0          0        0      -0.5*h*N(i)*V2(1)       0.5*h*N(i)*V1(1);
                        0        dNidr(i)   0      -0.5*t*h*dNidr(i)*V2(2) 0.5*t*h*dNidr(i)*V1(2);
                        0        dNids(i)   0      -0.5*t*h*dNids(i)*V2(2) 0.5*t*h*dNids(i)*V1(2);
                        0          0        0      -0.5*h*N(i)*V2(2)       0.5*h*N(i)*V1(2);
                        0          0      dNidr(i) -0.5*t*h*dNidr(i)*V2(3) 0.5*t*h*dNidr(i)*V1(3); 
                        0          0      dNids(i) -0.5*t*h*dNids(i)*V2(3) 0.5*t*h*dNids(i)*V1(3);
                        0          0        0      -0.5*h*N(i)*V2(3)       0.5*h*N(i)*V1(3)];
      end % node loop

      % Lund (2022) pp. 221 or Cook et al (2002) pp. 580
      Jac = [dxdr dydr dzdr;
             dxds dyds dzds;
             dxdt dydt dzdt];

      JacDet = det(Jac);

      % Matlab is slow at loops, so we compute B as H*G instead of using
      % the loop expression in Lund (2022) pp. 222, see Lund (2022) pp.
      % 223-224 or Cook et al (2002) Eqs. 16.5-7 - 16.5-10

      Gam = [inv(Jac) O      O;
             O      inv(Jac) O;
             O      O      inv(Jac)];
    
      Q_exp = [Q(:,:,1) Q(:,:,2) Q(:,:,3) Q(:,:,4) Q(:,:,5) Q(:,:,6) Q(:,:,7) Q(:,:,8) Q(:,:,9)];
        
      GMat = Gam*Q_exp;

      B = H*GMat;
      
      % Compute the strain vector (global coordinates)
      GPStrain(:,nGP,iGPt) = B*E.U(:,1);
    end % Gauss point loop in-plane   
  end % Gauss point loop thickness 

  % Having computed the strains at all Gauss points, we can now average the 
  % values to constant element values and extrapolate to bottom and top and.
  % First compute the averaged strains at the two Gauss points in thickness
  % direction:
  EGPStrain = sum(GPStrain,2)/nGPInplane;
  % Next perform linear extrapolation to bottom and top of each layer.
  % Linear 1D shape functions are N_1(r) = (1-r)/2 and N_2(r) = (1+r)/2
  % The r-coordinate for bottom and top are -sqrt(3) and sqrt(3), i.e.
  % the shape functions extrapolated becomes (1+sqrt(3))/2 and (1-sqrt(3))/2
  % Element strains at bottom (Pos=1) of layer:
  E.StrainXY(:,k,1) = (1+sqrt(3))/2*EGPStrain(:,1,1) + ...
                      (1-sqrt(3))/2*EGPStrain(:,1,2);
  % Element strains at top (Pos=2) of layer:
  E.StrainXY(:,k,2) = (1-sqrt(3))/2*EGPStrain(:,1,1) + ...
                      (1+sqrt(3))/2*EGPStrain(:,1,2);

  % Compute the element stresses in the global coordinate system
  CGlob = CLayerLoc(:,:,k);
  E.StressXY(:,k,1) = CGlob*E.StrainXY(:,k,1);
  E.StressXY(:,k,2) = CGlob*E.StrainXY(:,k,2);
  % Compute strain energy density and strain energy - we use the averaged
  % element values at bottom and top of the layer
  E.SED(k) = (sum(E.StrainXY(1:6,k,1).*E.StressXY(1:6,k,1)) + ...
              sum(E.StrainXY(1:6,k,2).*E.StressXY(1:6,k,2))) / 4;
  E.SE(k) = E.SED(k)*h_l(k)*E.Area;


  % MY ADDITION regarding global CS

%   T = InplaneRotationTMat(E.Layup.Angle(k));
% 
%   E.Stress12(:,k,1) = T * E.StressXY(:,k,1);
%   E.Stress12(:,k,2) = T * E.StressXY(:,k,2);
% 
%   E.Strain12(:,k,1) = transpose(T) \ E.StrainXY(:,k,1);
%   E.Strain12(:,k,2) = transpose(T) \ E.StrainXY(:,k,2);



end % Layer loop



% Further postprocessing can be added here:
% Determine strains and stresses in material coordinate system at bottom
% (pos = 1) and top (Pos = 2) of all layers. These should be stored in: 
% - E.Strain12(1:6, k, Pos): strains in material coordinate system 
% - E.Stress12(1:6, k, Pos): stresses in material coordinate system

% This is your task :-)
% --> Done above.

for k = 1:E.Layup.nLayers
  T = InplaneRotationTMat(E.Layup.Angle(k));

  E.Stress12(:,k,1) = T * E.StressXY(:,k,1);
  E.Stress12(:,k,2) = T * E.StressXY(:,k,2);

  E.Strain12(:,k,1) = transpose(T) \ E.StrainXY(:,k,1);
  E.Strain12(:,k,2) = transpose(T) \ E.StrainXY(:,k,2);
end

% Determine failure indices and modes
% In the plotting the order of failure indices is assumed to be
% ['maxstrain'; 'maxstress'; '  tsai-wu'] i.e.
% - E.FIdx(1, k, Pos): failure index computed using the max strain criterion
% - E.FIdx(2, k, Pos): failure index computed using the max stress criterion
% - E.FIdx(3, k, Pos): failure index computed using the Tsai-Wu criterion
% - E.FIdxMode(1, k, Pos) contains the failure mode predicted by max strain criterion
% - E.FIdxMode(2, k, Pos) contains the failure mode predicted by max stress criterion

% This is your task :-)
% done here:

% Loop through layers

% E.alpha = zeros(2,E.Layup.nLayers);

for k = 1:E.Layup.nLayers

    % parameters for Tsai-Wu
    F1  = 1/E.Mat(E.Layup.MatNo(k)).Xt - 1/E.Mat(E.Layup.MatNo(k)).Xc;
    F2  = 1/E.Mat(E.Layup.MatNo(k)).Yt - 1/E.Mat(E.Layup.MatNo(k)).Yc;
    F11 = 1/( E.Mat(E.Layup.MatNo(k)).Xt * E.Mat(E.Layup.MatNo(k)).Xc );
    F22 = 1/( E.Mat(E.Layup.MatNo(k)).Yt * E.Mat(E.Layup.MatNo(k)).Yc );
    F66 = 1/(E.Mat(E.Layup.MatNo(k)).S^2);
    F12 = -.5*sqrt( F11 * F22 );



    for pos = 1:2

        % max strain
        [E.FIdx(1, k, pos), E.FIdxMode(1, k, pos)] = max([ ...
            E.Strain12(1,k,pos) / E.Mat(E.Layup.MatNo(k)).eps1t, ...
            -E.Strain12(1,k,pos) / E.Mat(E.Layup.MatNo(k)).eps1c, ...
            E.Strain12(2,k,pos) / E.Mat(E.Layup.MatNo(k)).eps2t, ...
            -E.Strain12(2,k,pos) / E.Mat(E.Layup.MatNo(k)).eps2c, ...
            abs(E.Strain12(4,k,pos) / E.Mat(E.Layup.MatNo(k)).gamma12u), ...
            ]);


        % max stress
        [E.FIdx(2, k, pos), E.FIdxMode(2, k, pos)] = max([ ...
            E.Stress12(1,k,pos) / E.Mat(E.Layup.MatNo(k)).Xt, ...
            -E.Stress12(1,k,pos) / E.Mat(E.Layup.MatNo(k)).Xc, ...
            E.Stress12(2,k,pos) / E.Mat(E.Layup.MatNo(k)).Yt, ...
            -E.Stress12(2,k,pos) / E.Mat(E.Layup.MatNo(k)).Yc, ...
            abs(E.Stress12(4,k,pos) / E.Mat(E.Layup.MatNo(k)).S), ...
            ]);


       
        % Tsai Wu
        %find alpha
        alpha = roots([ F11 * E.Stress12(1,k,pos)^2 + ...
                        F22 * E.Stress12(2,k,pos)^2 + ...
                        F66 * E.Stress12(4,k,pos)^2 + ...
                        2*F12 * E.Stress12(1,k,pos) * E.Stress12(2,k,pos); ...
                        ...
                        F1*E.Stress12(1,k,pos) + F2*E.Stress12(2,k,pos); ...
                        -1]);

        alpha = min(alpha(alpha>0));


        % Check (E.FIdx=1 should be the overall result)
%         E.FIdx(3, k, pos) = alpha * (...
%             F1*E.Stress12(1,k,pos) + F2*E.Stress12(2,k,pos) + ...
%             F11*alpha*E.Stress12(1,k,pos)^2 + ...
%             F22*alpha*E.Stress12(2,k,pos)^2 + ...
%             F66*alpha*E.Stress12(4,k,pos)^2 + ...
%             2*F12*alpha*E.Stress12(1,k,pos)*E.Stress12(2,k,pos) ...
%             );

        % real shit
        E.FIdx(3, k, pos) = 1/alpha;
          


    end
end