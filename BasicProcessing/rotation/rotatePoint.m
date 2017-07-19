function [ op ] = rotatePoint( p, R )
%ROTATEPOINT Rotate points
%   p is point in 3D, R is rotation matrix
op = (R * p')';
end

