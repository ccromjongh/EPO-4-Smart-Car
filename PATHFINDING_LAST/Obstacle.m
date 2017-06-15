function FIELD = Obstacle(FIELD, r, n)

for i = 1:n;
    prompt = sprintf('x location obstacle %d  [cm] = ',i);
    Xb(i) = input(prompt)/5;
    prompt = sprintf('y location obstacle %d [cm] = ',i);
    Yb(i) = input(prompt)/5;
end

for i = 1:n;
    Xtemp = Xb(i);
    Ytemp = Yb(i);
    for k = 0:2*r
        for j = 0:2*r;
    FIELD(Ytemp-r+j,Xtemp-r+k) = 1;
        end
    end
end