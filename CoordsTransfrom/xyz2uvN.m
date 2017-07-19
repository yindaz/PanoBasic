function [ uv ] = xyz2uvN( xyz, planeID )
%XYZ2UVN Convert XYZ expression to UV expression in 3D
%   change 3-dim unit vector XYZ expression to UV in 3D
%   planeID: base plane for UV, 1=XY
%   Check uv2xyzN for opposite mapping
if ~exist('planeID', 'var')
    planeID = 1;
end

ID1 = rem(planeID-1+0,3)+1;
ID2 = rem(planeID-1+1,3)+1;
ID3 = rem(planeID-1+2,3)+1;

normXY = sqrt( xyz(:,ID1).^2+xyz(:,ID2).^2);
normXY(normXY<0.000001) = 0.000001;
normXYZ = sqrt( xyz(:,ID1).^2+xyz(:,ID2).^2+xyz(:,ID3).^2);
% 
v = asin(xyz(:,ID3)./normXYZ);

u = asin(xyz(:,ID1)./normXY);
valid = xyz(:,ID2)<0 & u>=0;
u(valid) = pi-u(valid);
valid = xyz(:,ID2)<0 & u<=0;
u(valid) = -pi-u(valid);

uv = [u v];
uv(isnan(uv(:,1)),1) = 0;
end

