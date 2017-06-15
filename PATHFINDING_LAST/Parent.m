function [OPEN] = Parent(OPEN, exp, c, i)
flag = 0;
for j=1:c
    ans = j
    if(exp(i,1) == OPEN(j,1) && exp(i,2) == OPEN(j,2) )
        OPEN(j,7)=min(OPEN(j,7),exp(i,5));
        if OPEN(j,7)== exp(i,5)
            %UPDATE PARENTS,gn,hn
            OPEN(j,3)=xnode;
            OPEN(j,4)=ynode;
            OPEN(j,5)=exp(i,3);
            OPEN(j,6)=exp(i,4);
        end;%End of minimum fn check
        flag=1;
    end;%End of node check
end