function [ uvcoord ] = uv2coords( uv, width, height, planeID )
%UV2COORDS Convert UV to image coordinates on panorama
%   Convert UV expression in 3D to pixel location on panorama image.
%   width and height are size of panorama image, width = 2 x height
%   planeID: the base plane for U, 1=XY
%   Check coords2uv for opposite mapping
if ~exist('planeID','var')
    planeID = 1;
end
if planeID~=1
    uv = xyz2uvN(uv2xyzN(uv, planeID), 1);
end

uvcoord = zeros(size(uv,1),2);
uvcoord(:,1) = min(round((uv(:,1)+pi)/2/pi*width+0.5), width);
uvcoord(:,2) = min(round((pi/2-uv(:,2))/pi*height+0.5), height);
end

