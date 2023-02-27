% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [E] = ElemK_Shell(E);

% This function determines the element stiffness matrix for a 9-node 
% isoparametric shell element. This is the general implementation.
%
% Input:  E      : Element data
%
% Output: E.K
%
% Documentation: Erik Lund (2022): Analysis of Composite Structures,
% Lecture notes for Ph.D. course on "Analysis and Gradient Based Optimization of
% Laminated Composite Structures", Aalborg University, May 2-6, 2022.
% See also Cook et al (2002): Concepts and Applications of Finite Element
% Analysis, 4th ed. John Wiley, ch. 16.5
% The code is based on previous work done together with colleagues and
% students including Jan Stegmann, Christian Frier Hvejsel and Henrik 
% Fredslund Hansen.

% Use 3 x 3 = 9 inplane Gauss Points, see Cook et al (2002) pp. 210 or 
% Lund (2022) pp. 263
nGPInplane = 9;
GVal=sqrt(0.6); 
GaussCoordsInplane = [-GVal -GVal; 0. -GVal; GVal -GVal; -GVal 0.; 0. 0.; GVal 0.; -GVal GVal; 0. GVal; GVal GVal];

% Number of Gauss points in thickness direction in each layer is 2
nGPThick = 2;
GValT = 1.0/sqrt(3.0); 
GaussCoordsThick = [-GValT GValT];

% Weight factors in-plane
W1 = 5.0/9.0;
W2 = 8.0/9.0;
WW = [W1*W1 W1*W2 W1*W1 W1*W2 W2*W2 W1*W2 W1*W1 W1*W2 W1*W1];

% Initialize array CLayerLoc containing all layer constitutive matrices
CLayerLoc = zeros(6,6,E.Layup.nLayers);

% Loop through layers and compute constitutive matrices transformed to the
% element coordinate system
for k = 1:E.Layup.nLayers
  [CLoc] = ConstitutiveMat(E, k);
  CLayerLoc(:,:,k) = CLoc;
end

% The total thickness is denoted h, see Lund (2022) pp. 204 and 227
h = E.Layup.tTotal;

% Saving layer thicknesses as vector h_l, see Lund (2022) pp. 227
h_l = E.Layup.t(1:E.Layup.nLayers); 

% Determine natural thickness coordinates of Gauss points, 
% see Lund (2022) pp. 227
t_Coor = zeros(E.Layup.nLayers, nGPThick);
hTop = 0.;
for k = 1:E.Layup.nLayers
  hTop = hTop + h_l(k);
  t_Coor(k,1) = -1+1/h*(2*hTop-h_l(k)*(1-GaussCoordsThick(1)));
  t_Coor(k,2) = -1+1/h*(2*hTop-h_l(k)*(1-GaussCoordsThick(2)));
end

% Determine the node directors V3, see Lund (2022) pp. 204 - 207. 
% We compute these elementwise, but for general structures they are
% normally obtained as nodal averaged directions (averaged between the
% values obtained from the elements that the node is connected to)

% Initialize V3
V3 = zeros(E.nNodes,3);
% Define the positions of the nodes in the natural coordinate system
NodeNatCoor = [-1 -1; 1 -1; 1 1; -1 1; 0 -1; 1 0; 0 1; -1 0; 0 0];

for NodeNo = 1:E.nNodes % Node loop
  r = NodeNatCoor(NodeNo,1);
  s = NodeNatCoor(NodeNo,2);
  % Get derivatives of shape functions wrt r and s
  [dNidr, dNids] = ShapeFunc9Deriv(r, s);
    
  xr = zeros(1,3); xs = zeros(1,3);
    
  for iNodeNo = 1:E.nNodes % Node loop to interpolate
    xr = xr + dNidr(iNodeNo)*E.X(iNodeNo,1:3);
    xs = xs + dNids(iNodeNo)*E.X(iNodeNo,1:3);    
  end % End node loop to interpolate
    
  V3(NodeNo,1:3) = cross(xr,xs)/norm(cross(xr,xs));
end % Node loop

% Define node coordinate systems (according to the scheme from 
% Lund (2022) pp. 207, see also Cook et al (2002) pp. 579)

% Initialize and allocate V1 and V2
V1 = zeros(E.nNodes,3);
V2 = zeros(E.nNodes,3);

for i = 1:E.nNodes
  j = [0 1 0];
  if (norm(cross(j,V3(i,:))) ~= 0.) % If V3 is NOT parallel to the second global unit base vector 
    V1(i,:)=cross(j,V3(i,:))/norm(cross(j,V3(i,:)));
    V2(i,:)=cross(V3(i,:),V1(i,:));
  else  % else another node coordinate system definition is used
    V2(i,:)=[1 0 0];
    V1(i,:)=[0 0 1];
  end
end

% ___________________Begin Stiffness matrix calculations____________________

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

% Initialize stiffness matrix
E.K = zeros(5*E.nNodes,5*E.nNodes);

% Loop through layers
for k = 1:E.Layup.nLayers

  % Loop over Gauss points in thickness direction, t
  for iGPt = 1:nGPThick
    t = t_Coor(k,iGPt);

    % Loop over Gauss points in-plane
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
      
      V1_Gauss(1:3) = 0.; V2_Gauss(1:3) = 0.; V3_Gauss(1:3) = 0.;
 
      for i = 1:E.nNodes % Loop over nodes to interpolate
        % Components of the Jacobian matrix (recursive summation, 
        % see Lund (2022) pp. 221 or Cook et al (2002) Eq. 16.5-4)
        dxdr = dxdr + dNidr(i)*(E.X(i,1)+0.5*t*h*V3(i,1));
        dydr = dydr + dNidr(i)*(E.X(i,2)+0.5*t*h*V3(i,2));
        dzdr = dzdr + dNidr(i)*(E.X(i,3)+0.5*t*h*V3(i,3));
        dxds = dxds + dNids(i)*(E.X(i,1)+0.5*t*h*V3(i,1));
        dyds = dyds + dNids(i)*(E.X(i,2)+0.5*t*h*V3(i,2));
        dzds = dzds + dNids(i)*(E.X(i,3)+0.5*t*h*V3(i,3));
        dxdt = dxdt + N(i)*0.5*h*V3(i,1);
        dydt = dydt + N(i)*0.5*h*V3(i,2);
        dzdt = dzdt + N(i)*0.5*h*V3(i,3);

        % Components of shape function derivatives wrt. natural coordinates, 
        % see Lund (2022) pp. 224 or Cook et al (2002) Eq. 16.5-9
        Q(1:9,1:5,i) = [dNidr(i)   0        0      -0.5*t*h*dNidr(i)*V2(i,1) 0.5*t*h*dNidr(i)*V1(i,1);
                        dNids(i)   0        0      -0.5*t*h*dNids(i)*V2(i,1) 0.5*t*h*dNids(i)*V1(i,1);
                        0          0        0      -0.5*h*N(i)*V2(i,1)       0.5*h*N(i)*V1(i,1);
                        0        dNidr(i)   0      -0.5*t*h*dNidr(i)*V2(i,2) 0.5*t*h*dNidr(i)*V1(i,2);
                        0        dNids(i)   0      -0.5*t*h*dNids(i)*V2(i,2) 0.5*t*h*dNids(i)*V1(i,2);
                        0          0        0      -0.5*h*N(i)*V2(i,2)       0.5*h*N(i)*V1(i,2);
                        0          0      dNidr(i) -0.5*t*h*dNidr(i)*V2(i,3) 0.5*t*h*dNidr(i)*V1(i,3); 
                        0          0      dNids(i) -0.5*t*h*dNids(i)*V2(i,3) 0.5*t*h*dNids(i)*V1(i,3);
                        0          0        0      -0.5*h*N(i)*V2(i,3)       0.5*h*N(i)*V1(i,3)];
          
        % Interpolate nodal coordinate systems to obtain local coordinate
        % system (V1,V2,V3) at Gauss points
        V1_Gauss = V1_Gauss + N(i)*V1(i,:);
        V2_Gauss = V2_Gauss + N(i)*V2(i,:);
        V3_Gauss = V3_Gauss + N(i)*V3(i,:);
      end % node loop

      % Lund (2022) pp. 221 or Cook et al (2002) pp. 580
      Jac = [dxdr dydr dzdr;
             dxds dyds dzds;
             dxdt dydt dzdt];

      % Set up the transformation from element coordinate system to the 
      % global coordinate system, see Lund (2022) pp. 218
      a = V1_Gauss;
      b = V2_Gauss;
      c = V3_Gauss;
  
      T= [a(1)*a(1)    b(1)*b(1)    c(1)*c(1)    a(1)*b(1)           b(1)*c(1)           c(1)*a(1);
          a(2)*a(2)    b(2)*b(2)    c(2)*c(2)    a(2)*b(2)           b(2)*c(2)           c(2)*a(2);
          a(3)*a(3)    b(3)*b(3)    c(3)*c(3)    a(3)*b(3)           b(3)*c(3)           c(3)*a(3);
          2*a(1)*a(2)  2*b(1)*b(2)  2*c(1)*c(2)  a(1)*b(2)+a(2)*b(1) b(1)*c(2)+b(2)*c(1) c(1)*a(2)+c(2)*a(1);
          2*a(2)*a(3)  2*b(2)*b(3)  2*c(2)*c(3)  a(2)*b(3)+a(3)*b(2) b(2)*c(3)+b(3)*c(2) c(2)*a(3)+c(3)*a(2);
          2*a(1)*a(3)  2*b(1)*b(3)  2*c(1)*c(3)  a(1)*b(3)+a(3)*b(1) b(1)*c(3)+b(3)*c(1) c(1)*a(3)+c(3)*a(1)];

      % Transform the constitutive matrix to global coordinate system
      CGlob = T'*CLayerLoc(:,:,k)*T;
        
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
      Ktemp = B'*CGlob*B;
      % Stiffness matrix recursive summation
      E.K = E.K + Ktemp*WW(nGP)*JacDet*h_l(k)/h;

    end % Gauss point loop in-plane   
  end % Gauss point loop thickness 
end % Layer loop
