function [cpath] = AnglePoint(Optimal_path)
path = flipud(Optimal_path);
n = length(path);
for i = 1:n-4
    p1 = path(i+2,:);                               %getpoints
    p3 = path(i+4,:);
    p2 = path(i,:) + 2*(path(i+2,:) - path(i,:));
    
    v1 = p1 - p2;
    x1 = v1(1);
    y1 = v1(2);
    v2 = p3 - p1;
    x2 = v2(1);
    y2 = v2(2);
    
    angle = atan2d(y1,x1) - atan2d(y2,x2);          %get angles
    
    if abs(angle) == 180
        angle = 0;
    else
        angle = 180 - angle;
    end
    
    if abs(angle) > 180
        angleout(i) = angle - 360*sign(angle);
    else
        angleout(i) = angle;
    end
    
end
cpath = [];
for j = 1:length(path)-4
    if abs(angleout(j)) > 0 && abs(angleout(j)) < 45
        cpath = [cpath; path(j,:)];
        cpath = [cpath; path(j+4,:)];
    end
end
% cpath = [cpath; cpath(length(cpath),:)]; test for duplications
for i = 2:length(cpath)
    if isequal(cpath(i,:), cpath(i-1,:)) == 1
        cpath(i,:) = [];
    end
end