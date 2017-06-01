rc = (Yg - yloc) / (Xg - xloc);
b = yloc;
xf = 0:1:10;
yf = rc*xf + b;
anglet = atan(rc);            %angle turn
plot(yf,':')
hold on
%% angle comoparison
if angle < anglet%determine smallest angle
    d1 = abs(angle-anglet);
    d2 = 2*pi - d1;
    if d1 < d2
        dir = 'left';
    else if d2 <d1
            dir = 'right';
        else
            dir ='forward';
        end
    end
else if angle > anglet%determine smallest angle
        d1 = abs(anglet - angle);
        d2 = 2*pi - d1;
        if d1 < d2
            dir = 'right';
        else if d2 <d1
              dir = 'left';
            else
             dir ='forward';
            end
        end
    end
end
%% turning
th = 0:pi/50:2*pi;
s1 = 'left';
s2 = 'right';
if strcmp(dir,s1) == 1
anglel = angle + 0.5*pi;        %angle left
mp(1) = xloc+r*cos(anglel);    %middelpunt left x
mp(2) = yloc+r*(sin(anglel));  %middelpunt left y
xcir = r * cos(th) + mp(1);   %turn circle left
ycir = r * sin(th) + mp(2);
circle(mp(1),mp(2),r,':')
hold on
plot(mp(1),mp(2),'xr')
hold on
end
if strcmp(dir,s2) == 1
angler = angle - 0.5*pi;        %angle right
mp(1) = xloc+r*cos(angler);    %middelpunt right x
mp(2) = yloc+r*(sin(angler));  %middelpunt right y
xcir = r * cos(th) + mp(1);   %turn circle right
ycir = r * sin(th) + mp(2);
plot(mp(1),mp(2),'xr')
hold on
circle(mp(1),mp(2),r,':')

end
%% raaklijn
% for i = 1:length(th)
% rc = (xcir(i) - mp(1)) / (ycir(i) - mp(2));
% xf2 = 0:1:10;
% b = ycir(i) - rc*xcir(i);
% yf2 = rc*xf2 + b;
%         plot(yf2);
%         hold on
% 
%     if Yg == (Xg*xf2 + b)
%         break
%     end
% end
%-------------------------------------------------------------

