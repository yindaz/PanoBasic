function [ out ] = computeUVN( n, in, planeID )
%COMPUTEUVN compute v given u and normal.
%   A point on unit sphere can be represented as (u,v). Sometimes we only
%   have u and the normal direction of the great circle that point locates
%   on, and want to to get v.
%   planeID: which plane we choose for uv expression. planeID=1 means u is
%   in XY plane. planeID=2 means u is in YZ plane.


if planeID==2
    n = [n(2) n(3) n(1)];
end
if planeID==3
    n = [n(3) n(1) n(2)];
end
bc = n(1)*sin(in) + n(2)*cos(in);
bs = n(3);
out = atan(-bc/bs);
end

