%% a demo of PanoBasic
clear all
add_path;


%% Project to perspective views
% read image
panoImg = imread('./data/pano_abbvryjplnajxo.jpg');
panoImg = im2double(panoImg);

% project it to multiple perspective views
cutSize = 320; % size of perspective views
fov = pi/3; % horizontal field of view of perspective views
xh = -pi:(pi/6):(5/6*pi);
yh = zeros(1, length(xh));
xp = [-3/3 -2/3 -1/3 +0/3 +1/3 +2/3 -3/3 -2/3 -1/3 +0/3 +1/3 +2/3] * pi;
yp = [ 1/4  1/4  1/4  1/4  1/4  1/4 -1/4 -1/4 -1/4 -1/4 -1/4 -1/4] * pi;
x = [xh xp 0     0];
y = [yh yp +pi/2 -pi/2]; % viewing direction of perspective views

[sepScene] = separatePano( panoImg, fov, x, y, cutSize);

%% visualization: random display 9 perspective views
ID = randsample(length(sepScene), 9);

figure(1);
uv = [x(ID)' y(ID)'];
coords = uv2coords(uv, 1024, 512);
imshow(imresize(panoImg, [512, 1024])); hold on
for i = 1:9
    scatter(coords(i,1),coords(i,2), 40, [1 0 0],'fill');
    text(coords(i,1)+8, coords(i,2),sprintf('%d', i), ...
        'BackgroundColor',[.7 .9 .7], ...
        'Color', [1 0 0]); 
end
title('Project viewpoints to perspective views: Image');

figure(2);
for i = 1:9
    subplot(3,3,i);
    imshow(sepScene(ID(i)).img);
    title(sprintf('%d: (%3.2f, %3.2f)', ...
        i, sepScene(ID(i)).vx, sepScene(ID(i)).vy));
end

%% Line segment detection on panorama: first on perspective views and project back to panorama
numScene = length(sepScene);
qError = 0.7;
edge(numScene) = struct('img',[],'edgeLst',[],'vx',[],'vy',[],'fov',[]);
for i = 1:numScene
    cmdline = sprintf('-q %f ', qError);
    [ edgeMap, edgeList ] = lsdWrap( sepScene(i).img, cmdline);
    edge(i).img = edgeMap;
    edge(i).edgeLst = edgeList;
    edge(i).fov = sepScene(i).fov;
    edge(i).vx = sepScene(i).vx;
    edge(i).vy = sepScene(i).vy;
    edge(i).panoLst = edgeFromImg2Pano( edge(i) );
end
[lines,olines] = combineEdgesN( edge); % combine line segments from views
panoEdge = paintParameterLine( lines, 1024, 512); % paint parameterized line segments

%% visualize line segments
figure(3); imshow(panoEdge); hold on
for i = 1:9
    scatter(coords(i,1),coords(i,2), 40, [1 0 0],'fill');
    text(coords(i,1)+8, coords(i,2),sprintf('%d', i), ...
        'BackgroundColor',[.7 .9 .7], ...
        'Color', [1 0 0]); 
end
title('Project viewpoints to perspective views: Line segment map');

figure(4);
for i = 1:9
    subplot(3,3,i);
    imshow(edge(ID(i)).img);
    title(sprintf('%d: (%3.2f, %3.2f)', ...
        i, sepScene(ID(i)).vx, sepScene(ID(i)).vy));
end

%% estimating vanishing point: Hough 
[ olines, mainDirect] = vpEstimationPano( lines ); % mainDirect is vanishing point, in xyz format
vpCoords = uv2coords(xyz2uvN(mainDirect), 1024, 512); % transfer to uv format, then image coords

imgres = imresize(panoImg, [512 1024]);
panoEdge1r = paintParameterLine( olines(1).line, 1024, 512, imgres);
panoEdge2r = paintParameterLine( olines(2).line, 1024, 512, imgres);
panoEdge3r = paintParameterLine( olines(3).line, 1024, 512, imgres);
panoEdgeVP = cat(3, panoEdge1r, panoEdge2r, panoEdge3r);
figure(5);
imshow(panoEdgeVP); hold on
color = 'rgb';
for i = 1:3
    scatter(vpCoords(i,1), vpCoords(i,2), 100, color(i),'fill','s');
    scatter(vpCoords(i+3,1), vpCoords(i+3,2), 100, color(i),'fill','s');
end
title('Vanishing points and assigned line segments');

%% rotate panorama to coordinates spanned by vanishing directions
vp = mainDirect(3:-1:1,:);
[ rotImg, R ] = rotatePanorama( imgres, vp );
[ newMainDirect ] = rotatePoint( mainDirect, R );
panoEdge1r = paintParameterLine( rotateLines(olines(1).line, R), 1024, 512, rotImg);
panoEdge2r = paintParameterLine( rotateLines(olines(2).line, R), 1024, 512, rotImg);
panoEdge3r = paintParameterLine( rotateLines(olines(3).line, R), 1024, 512, rotImg);
newPanoEdgeVP = cat(3, panoEdge1r, panoEdge2r, panoEdge3r);


figure(6);
subplot(2,1,1); imshow(panoEdgeVP); hold on
for i = 1:3
    scatter(vpCoords(i,1), vpCoords(i,2), 100, color(i),'fill','s');
    scatter(vpCoords(i+3,1), vpCoords(i+3,2), 100, color(i),'fill','s');
end
title('Original image');

subplot(2,1,2); imshow(newPanoEdgeVP); hold on
newVpCoords = uv2coords(xyz2uvN(newMainDirect), 1024, 512);
for i = 1:3
    scatter(newVpCoords(i,1), newVpCoords(i,2), 100, color(i),'fill','s');
    scatter(newVpCoords(i+3,1), newVpCoords(i+3,2), 100, color(i),'fill','s');
end
title('Rotated image');

%% image segmentation: 
[ panoSegment ] = gbPanoSegment( im2uint8(rotImg), 0.5, 200, 50 );
figure(7);
imshow(panoSegment,[]);
title('Segmentation: left and right are connected');

%% Get region inside a polygon
load('./data/points.mat'); % load room corner
load('./icosahedron2sphere/uniformvector_lvl8.mat'); % load vectors uniformly on sphere
vcs = uv2coords(xyz2uvN(coor), 1024, 512); % transfer vectors to image coordinates
coords = uv2coords(xyz2uvN(points), 1024, 512);

[ s_xyz, ~] = sortXYZ( points(1:4,:) ); % define a region with 4 vertices
[ inside, ~, ~ ] = insideCone( s_xyz(end:-1:1,:), coor, 0 ); % test which vectors are in region

figure(8); imshow(rotImg); hold on
for i = 1:4
    scatter(coords(i,1), coords(i,2), 100, [1 0 0],'fill','s');
end
for i = find(inside)
    scatter(vcs(i,1), vcs(i,2), 1, [0 1 0],'fill','o');
end

[ s_xyz, I ] = sortXYZ( points(5:8,:) );
[ inside, ~, ~ ] = insideCone( s_xyz(end:-1:1,:), coor, 0 );
for i = 5:8
    scatter(coords(i,1), coords(i,2), 100, [1 0 0],'fill','s');
end
for i = find(inside)
    scatter(vcs(i,1), vcs(i,2), 1, [0 0 1],'fill','o');
end
title('Display of two wall regions');

%% Reconstruct a box, assuming perfect upperright cuboid
D3point = zeros(8,3);
pointUV = xyz2uvN(points);
floor = -160;

floorPtID = [2 3 6 7 2];
ceilPtID = [1 4 5 8 1];
for i = 1:4
    D3point(floorPtID(i),:) = LineFaceIntersection( [0 0 floor], [0 0 1], [0 0 0], points(floorPtID(i),:) );
    D3point(ceilPtID(i),3) = D3point(floorPtID(i),3)/tan(pointUV(floorPtID(i),2))*tan(pointUV(ceilPtID(i),2));
end
ceiling = mean(D3point(ceilPtID,3));
for i = 1:4
    D3point(ceilPtID(i),:) = LineFaceIntersection( [0 0 ceiling], [0 0 1], [0 0 0], points(ceilPtID(i),:) );
end
figure(9);
plot3(D3point(floorPtID,1), D3point(floorPtID,2), D3point(floorPtID,3)); hold on
plot3(D3point(ceilPtID,1), D3point(ceilPtID,2), D3point(ceilPtID,3));
for i = 1:4
    plot3(D3point([floorPtID(i) ceilPtID(i)],1), D3point([floorPtID(i) ceilPtID(i)],2), D3point([floorPtID(i) ceilPtID(i)],3));
end
title('Basic 3D reconstruction');

figure(10); 
firstID = [1 4 5 8 2 3 6 7 1 4 5 8];
secndID = [4 5 8 1 3 6 7 2 2 3 6 7];
lines = lineFromTwoPoint(points(firstID,:), points(secndID,:));
imshow(paintParameterLine(lines, 1024, 512, rotImg)); hold on
for i = 1:8
    scatter(coords(i,1), coords(i,2), 100, [1 0 0],'fill','s');
end
title('Get lines by two points');















