function p = circle(x, y, r, LineSpec)
    %x and y are the coordinates of the center of the circle
    %r is the radius of the circle
    %0.01 is the angle step, bigger values will draw the circle faster but
    %you might notice imperfections (not very smooth)
    if (nargin < 4)
       LineSpec = '-'; 
    end
    
    ang = 0:0.01:2*pi;
    xp = r*cos(ang);
    yp = r*sin(ang);
    p = plot(x+xp, y+yp, LineSpec, 'LineWidth', 1.05);
end