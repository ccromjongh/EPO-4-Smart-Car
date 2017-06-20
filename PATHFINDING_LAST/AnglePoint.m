function [c_sorted] = AnglePoint(Optimal_path)
%function checks segments of 5 points, takes the middle and end points in
%order to calculate the angle. For angles between 0 and 45 degrees, the end
%points are returned.
path = flipud(Optimal_path);
n = length(path);

%% get points
for i = 1:n-4
    p1 = path(i+2,:);                               %get points
    p3 = path(i+4,:);
    p2 = path(i,:) + 2*(path(i+2,:) - path(i,:));   %extrapolate one of the points to calculate the angle
    
    v1 = p1 - p2;                                   %make vectors out of the points
    x1 = v1(1);
    y1 = v1(2);
    v2 = p3 - p1;
    x2 = v2(1);
    y2 = v2(2);
    
    angle = atan2d(y1,x1) - atan2d(y2,x2);          %get angle between vectors
    
    if abs(angle) == 180                            %make 180 deg. angles 0 deg, just in case
        angle = 0;
    else
        angle = 180 - angle;                        %get the actual angle, not the angle with the extrapolation
    end
    
    if abs(angle) > 180                             %angles between 0 and 180 deg
        angleout(i) = angle - 360*sign(angle);
    else
        angleout(i) = angle;
    end
end
%% make the path
cpath = [];                                         %paste all the points together
for j = 1:length(path)-4
    if abs(angleout(j)) > 0 && abs(angleout(j)) < 45
        cpath = [cpath; path(j,:)];
        cpath = [cpath; path(j+4,:)];
    end
end
% cpath = [cpath; cpath(length(cpath),:)]; test for duplications
for i = 2:length(cpath)                             %get rid of duplicants (not sure if needed)
    if isequal(cpath(i,:), cpath(i-1,:)) == 1
        cpath(i,:) = [];
    end
end

%% index the path
c_sorted = zeros(length(path),2);                   %set the points in actual order
for j = 1:length(cpath)
    for i = 1:length(path)
        if isequal(path(i,:), cpath(j,:)) == 1
            c_sorted(i,:) = cpath(j,:);
        end
    end
end

c_sorted( all(~c_sorted,2), : ) = [];               %give the proper path as output