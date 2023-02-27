function [G] = ABD(G, A)
%ABD Summary of this function goes here
%   Detailed explanation goes here

G.A = zeros(6);
G.B = zeros(6);
G.D = zeros(6);
N = G.Layup.nLayers;
G.Layup.z = zeros(N+1,1);
G.Layup.z(1) = - sum(G.Layup.t)/2;

for i=1:N
    G.Layup.z(i+1) = - sum(G.Layup.t)/2 + sum(G.Layup.t(1:i));
end

for i = [1,2,4]
    for j = [1,2,4]
        for k=1:N
            G.A(i,j) = G.A(i,j) + A.CLayerLoc(i,j,k) * (G.Layup.z(k+1) - G.Layup.z(k));
            G.B(i,j) = G.B(i,j) + A.CLayerLoc(i,j,k) * (G.Layup.z(k+1)^2 - G.Layup.z(k)^2);
            G.D(i,j) = G.D(i,j) + A.CLayerLoc(i,j,k) * (G.Layup.z(k+1)^3 - G.Layup.z(k)^3);
        end
        G.B(i,j) = 1/2 * G.B(i,j);
        G.D(i,j) = 1/3 * G.D(i,j);
    end
end

G.A([3,5,6],:) = [];
G.A(:,[3,5,6]) = [];
G.B([3,5,6],:) = [];
G.B(:,[3,5,6]) = [];
G.D([3,5,6],:) = [];
G.D(:,[3,5,6]) = [];

G.StiffMat = [G.A, G.B; G.B, G.D];
end

