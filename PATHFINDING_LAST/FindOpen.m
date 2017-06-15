function exp = FindOpen(xnode,ynode,h,xt,yt,CLOSED,Xmax,Ymax, xparent, yparent)
exp = [];
count = 1;
c1 = size(CLOSED,1);
for k= 1:-1:-1
    for j= 1:-1:-1
        if (k~=j || k~=0)  %The node itself is not in open
            sx = xnode+k;
            sy = ynode+j;
            if( (sx >0 && sx <=Xmax) && (sy >0 && sy <=Ymax))%node within FIELD
                flag=1;
                for c2=1:c1
                    if(sx == CLOSED(c2,1) && sy == CLOSED(c2,2))
                        flag=0;
                    end;
                end
                if flag == 1
                    cost = RedCost(xnode, ynode, xparent, yparent,sx,sy); %higher cost for not going forward 
                    exp(count,1) = sx;
                    exp(count,2) = sy;
                    exp(count,3) = h+dist(xnode,ynode,sx,sy);  %h
                    exp(count,4) = dist(xt,yt,sx,sy);          %g
                    exp(count,5) = exp(count,3)+exp(count,4)+cost; %f
                    count = count + 1;
                end
            end
        end
    end
end