function FIELD = Obstacle(FIELD, r, n,res)

for i = 1:n;
    prompt = sprintf('x location obstacle %d  [cm] = ',i);
    Xb(i) = ceil(input(prompt)/res);
    prompt = sprintf('y location obstacle %d [cm] = ',i);
    Yb(i) = ceil(input(prompt)/res);
end

for i = 1:n;
    Xtemp = Xb(i);
    Ytemp = Yb(i);
    r2 = ceil(2*r/res);
    r1 = ceil(r2/2);
    for k = -r1:1:r1
        for j = -r1:1:r1;
    FIELD(Ytemp+j,Xtemp+k) = 1;
        end
    end
end