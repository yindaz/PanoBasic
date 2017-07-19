function [ olines, mainDirect] = vpEstimationPano( lines )
%VPESTIMATION Estimate vanishing points via lines
%   lines: all lines in format of [nx ny nz projectPlaneID umin umax LSfov score]
%   olines: line segments in three directions
%   mainDirect: vanishing points

clines = lines;
for iter = 1:3
    fprintf('*************%d-th iteration:****************\n', iter);
    [mainDirect, score, angle] = findMainDirectionEMA( clines );    % search for main directions
    
    [ type, typeCost ] = assignVanishingType( lines, mainDirect(1:3,:), 0.1, 10 ); % assign directions to line segments
    lines1 = lines(type==1,:);
    lines2 = lines(type==2,:);
    lines3 = lines(type==3,:);
    
    % slightly change line segment to fit vanishing direction.
    % the last parameter controls strenght of fitting, here 0 means no
    % fitting, inf means line segments are forced to vp. Sometimes, fitting
    % could be helpful when big noise in line segment estimation.
    lines1rB = refitLineSegmentB(lines1, mainDirect(1,:), 0); 
    lines2rB = refitLineSegmentB(lines2, mainDirect(2,:), 0);
    lines3rB = refitLineSegmentB(lines3, mainDirect(3,:), 0);
    
    clines = [lines1rB;lines2rB;lines3rB];
end

[ type, typeCost ] = assignVanishingType( lines, mainDirect(1:3,:), 0.1, 10 );
lines1rB = lines(type==1,:);
lines2rB = lines(type==2,:);
lines3rB = lines(type==3,:);
% clines = [lines1rB;lines2rB;lines3rB];
olines(1).line = lines1rB;
olines(2).line = lines2rB;
olines(3).line = lines3rB;

end

