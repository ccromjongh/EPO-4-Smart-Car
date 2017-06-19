%OPEN: 1:X|2:Y|3:xpar|4:ypar|5:H|6:G|7:F|
%closed count = cc
%open count = c
%exp count = ce
%% start
OPEN = zeros(1,8);
%% finish
xt = Xg;
yt = Yg;
%% lists
CLOSED = [];
c = 1;

%% counter
k=1;
for i=1:Xmax
    for j=1:Ymax
        if(FIELD(j,i) == 1)
            CLOSED(k,1)=i;
            CLOSED(k,2)=j;
            k=k+1;
        end
    end
end

cc =size(CLOSED,1);

xnode=Xs;
Xstart = Xs;
ynode=Ys;
Ystart = Ys;


path=0;
goal_distance=dist(xnode,ynode,xt,yt);
OPEN(c,:)= NewOpen(xnode,ynode,orx,ory,path,goal_distance,goal_distance);
OPEN(c,8)=0;
cc=cc+1;
CLOSED(cc,1)=xnode;
CLOSED(cc,2)=ynode;
NoPath=1;

xparent = orx;
yparent = orx;

%% A* algorithm
flag = 0;
while (xnode ~= xt || ynode ~= yt) && (flag == 0)
    exp = FindOpen(xnode,ynode,path,xt,yt,CLOSED,Xmax,Ymax,xparent,yparent);
    ce = size(exp,1);
    trig = 0;
    for i=1:ce
            trig = 0;
        for j=1:c
            if(exp(i,1) == OPEN(j,1) && exp(i,2) == OPEN(j,2) )
                OPEN(j,7)=min(OPEN(j,7),exp(i,5));
                if OPEN(j,7)== exp(i,5)
                    %UPDATE PARENTS,gn,hn
                    OPEN(j,3)=xnode;
                    OPEN(j,4)=ynode;
                    OPEN(j,5)=exp(i,3);
                    OPEN(j,6)=exp(i,4);
                end;%End of minimum fn check
                trig=1;
            end;%End of node check
        end
        
        if trig == 0                                                        %insert new element in OPEN list
            c = c+1;
            OPEN(c,:) = NewOpen(exp(i,1),exp(i,2),xnode,ynode,exp(i,3),exp(i,4),exp(i,5));
        end;                                                                   %insert new element into the OPEN list
    end
    [imin ans]= NewNode(OPEN,c,xt,yt);
    if (imin ~= -1)
        xnode=OPEN(imin,1);
        ynode=OPEN(imin,2);
        path=OPEN(imin,5);
        cc=cc+1;
        CLOSED(cc,1)=xnode;
        CLOSED(cc,2)=ynode;
        OPEN(imin,8)=0;
        xparent = OPEN(imin,3);
        yparent = OPEN(imin,4);
    else
        NoPath=0;
        flag = 1;
    end;
end


%% Path
figure(1)
i=size(CLOSED,1);
Optimal_path=[];
Xs=CLOSED(i,1);
Ys=CLOSED(i,2);

i=1;
Optimal_path(i,1)=Xs;
Optimal_path(i,2)=Ys;
i=i+1;

if ( (Xs == xt) && (Ys == yt))
    inode=0;
    %         Traverse OPEN and determine the parent nodes
    xp=OPEN(nindex(OPEN,Xs,Ys),3);                                          %nindex returns the index of the node
    yp=OPEN(nindex(OPEN,Xs,Ys),4);
    
    while( xp ~= Xstart || yp ~= Ystart)
        Optimal_path(i,1) = xp;
        Optimal_path(i,2) = yp;
        
        inode=nindex(OPEN,xp,yp);
        xp=OPEN(inode,3);                                                   %node_index returns the index of the node
        yp=OPEN(inode,4);
        i=i+1;
    end;
    
    Optimal_path(i,1) = xp;
    Optimal_path(i,2) = yp;
    
    j=size(Optimal_path,1);
    %       Plot the Optimal Path!
    p=plot(Optimal_path(j,1),Optimal_path(j,2),'bo');
    j=j-1;
    for i=j:-1:1
%         pause(.25);
        set(p,'XData',Optimal_path(i,1),'YData',Optimal_path(i,2));
        drawnow ;
    end;
    plot(Optimal_path(:,1),Optimal_path(:,2));
    xlim([0.5 Xmax+0.5]);
    ylim([0.5 Ymax+0.5]);
    grid on;
    
    set(gca,'Ydir','normal')
else
    pause(1);
    h=msgbox('Sorry, No path exists to the Target!','warn');
    uiwait(h,5);
end