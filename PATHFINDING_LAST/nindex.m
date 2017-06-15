function nindex = nindex(OPEN,Xs,Ys)
i=1;
    while(OPEN(i,1) ~= Xs || OPEN(i,2) ~= Ys )
        i=i+1;
    end;
    nindex=i;
end