%xbrake = afgelegdeafstand waarop auto remt
%X0 = virtuele stoppunt
%Xa = actuele afgeleggde afstand
%Td = delay time
%Xm = measured distance (to target)
%Va = actual velocity
run 'KITTParameters.m'                           %open parameters bestand
xbrake = 5;                                       %set max brake distance
[v1,x1] = KITTVelocity();                         %expected start path

%plot expected path
plot(x1,v1)
xlim([0 6])
ylim([0 8])

ta = x.time;                                      %read time
xa = x.Data;                                      %read distance
va = v.Data;                                      %read velocity

i=1;
t = zeros(1,length(x1));                          %declare t for speed
tic                                               %start timer
while i<length(x1)
    t(i) = toc;
    Td = 0.2;
    X0 = 0;
    k=0;
        %find position and velocity at current time
        for k = 1:length(x1)
            if ta(k) > t(i)
                Xa = xa(k);
                Va = va(k);
                break
            end
        end
        

        xbrake = Xa;                %set brake distance at current position
        [v2,x2] = KITTVelocity();   %simulate with current distance as brakepoint
        
        %
        for j = 2:length(x1)
            if v2(j) <= 0.01
            X0 = x2(j);
            Xm =1;              %read measured distance
            break
            end
        end
%---------Implementation---------------------------------------------------
%         switch Xm
%             case Xm <=(X0-Xa -(Va*Td)
%                 i=1000;
%                 break
%         end
%-----------------TEST VOORWAARDE-----------------------------------------
        if Xm <= (X0-Xa +(Va*Td))
           figure(2)
           plot(x2,v2)
           xlim([0 6])
           ylim([0 8])
           break
        end
%-------------------------------------------------------------------------
        i = i+1;
end