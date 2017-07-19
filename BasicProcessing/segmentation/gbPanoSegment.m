function [ panoSegment ] = gbPanoSegment( img, sigma, k, minSz )
%GBPANOSEGMENT Graph-based image segmentation on panorama
%   Similar as Pedro's algorithm, only the graph is built on sphere, so
%   left and right side are considered as attached.
%   img: should be in uint8 [0~256]
%   sigma, k, minSz: same parameters as in Pedro's algorithm

[height, width, ~] = size(img);
img_smooth = smooth(img, sigma);

%% uniformly sample vectors on sphere and segment, test later
load('./icosahedron2sphere/uniformvector_lvl8.mat');
%[coor, tri] = getUniformVector(8);

% [ E ] = getSketchTokenEdgemap( img );
% [EE, Ix, Iy] = dt2(double(E), 0.1, 0, 0.1, 0 );
EE = zeros(height, width);

xySubs = uv2coords(xyz2uvN(coor), width, height);
xyinds = sub2ind([height width], xySubs(:,2), xySubs(:,1));
offset = width*height;

edges = [tri(:,1) tri(:,2); tri(:,2) tri(:,3); tri(:,3) tri(:,1)];
invert = edges(:,2)<edges(:,1);
edges(invert,:) = edges(invert,[2 1]);

uniEdges = unique(edges, 'rows');
weight = (img_smooth(xyinds(uniEdges(:,1)))-img_smooth(xyinds(uniEdges(:,2)))).^2 ...
       + (img_smooth(xyinds(uniEdges(:,1))+offset)-img_smooth(xyinds(uniEdges(:,2))+offset)).^2 ...
       + (img_smooth(xyinds(uniEdges(:,1))+2*offset)-img_smooth(xyinds(uniEdges(:,2))+2*offset)).^2;
gdweight = (EE(xyinds(uniEdges(:,1)))+EE(xyinds(uniEdges(:,2))))/2;
panoEdge = [uniEdges(:,1)'; uniEdges(:,2)'; sqrt(weight)'+10*double(gdweight)'];

maxID = size(coor,1);
num = size(uniEdges,1);

edgeLabel = segmentGraphMex_edge(maxID, num, panoEdge, k, minSz);

L = unique(edgeLabel);
temp = zeros(size(edgeLabel));

[gridX, gridY] = meshgrid(1:width, 1:height);
for i = 1:length(L)
    temp(edgeLabel==L(i)) = i;
end


pixelvector = uv2xyzN(coords2uv([gridX(:) gridY(:)], width, height));

% k = 1;
% [nnidx, dists] = annsearch( coor', pixelvector', k);
[nnidx, dists] = knnsearch( coor, pixelvector);

panoSegment = reshape(temp(nnidx), height, width);


end

