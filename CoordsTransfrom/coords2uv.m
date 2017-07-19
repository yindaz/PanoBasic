function [ uv ] = coords2uv( coords, width, height )
%COORDS2UV Image coordinates (xy) to uv
%   Convert pixel location on panorama image to UV expression in 3D
%   width and height are size of panorama image, width = 2 x height
%   the output UV take XY plane for U
%   Check uv2coords for opposite mapping
middleX = width/2+0.5;
middleY = height/2+0.5;
uv = [(coords(:,1)-middleX)./width*2*pi -(coords(:,2)-middleY)./height*pi];

end

