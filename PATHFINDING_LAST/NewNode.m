function [imin] = NewNode(OPEN,c,xt,yt)

temp=[];
k=1;
flag=0;
gindex=0;
for j=1:c                              %check if target is in OPEN
         if (OPEN(j,8)==1)

        temp(k,:)=[OPEN(j,:) j];
        if (OPEN(j,1)==xt && OPEN(j,2)==yt)
            flag=1;
            gindex=j;                           %index of the goal node
        end;
        k=k+1;
end;
end
if flag == 1 % goal is in OPEN
    imin=gindex;
    
end

%Send the index of the smallest node
if size(temp ~= 0)
    [minf,tempmin]=min(temp(:,7));%Index of the smallest node in temp array
    imin=temp(tempmin,9);%Index of the smallest node in the OPEN array
else
    imin=-1;%The temp_array is empty i.e No more paths are available.
end;
