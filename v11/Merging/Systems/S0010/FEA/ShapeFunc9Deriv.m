% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [dNidr, dNids] = ShapeFunc9Deriv(r, s)

% Derivatives of shape functions wrt r
dN1dr = .25*s-.25*s^2-.50*r*(1-s^2)+.50*r*(1-s);
dN2dr = -.25*s+.50*r*(1-s)-.50*r*(1-s^2)+.25*s^2;
dN3dr = .25*s+.25*s^2-.50*r*(1-s^2)+.50*r*(1+s);
dN4dr = -.25*s+.50*r*(1+s)-.50*r*(1-s^2)-.25*s^2;
dN5dr = -1.0*r*(1-s)+1.0*r*(1-s^2);
dN6dr = .5-.5*s^2+1.0*r*(1-s^2);
dN7dr = -1.0*r*(1+s)+1.0*r*(1-s^2);
dN8dr = -.5+.5*s^2+1.0*r*(1-s^2);
dN9dr = -2.*r*(1-s*s);
dNidr = [dN1dr dN2dr dN3dr dN4dr dN5dr dN6dr dN7dr dN8dr dN9dr];

% Derivatives of shape functions wrt s
dN1ds = .25*r+.50*(1-r)*s-.50*(1-r^2)*s-.25*r^2;
dN2ds = -.25*r-.25*r^2-.50*(1-r^2)*s+.50*(1+r)*s;
dN3ds = .25*r+.50*(1+r)*s-.50*(1-r^2)*s+.25*r^2;
dN4ds = -.25*r+.25*r^2-.50*(1-r^2)*s+.50*(1-r)*s;
dN5ds = -.5+.5*r^2+1.0*(1-r^2)*s;
dN6ds = -1.0*(1+r)*s+1.0*(1-r^2)*s;
dN7ds = .5-.5*r^2+1.0*(1-r^2)*s;
dN8ds = -1.0*(1-r)*s+1.0*(1-r^2)*s;
dN9ds = -2.*s*(1-r*r);
dNids = [dN1ds dN2ds dN3ds dN4ds dN5ds dN6ds dN7ds dN8ds dN9ds];
