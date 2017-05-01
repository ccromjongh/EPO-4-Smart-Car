%direction keys
function directionkeys()

c=0;
while  c <= 4;
w = waitforbuttonpress;
if w
       dir = get(gcf, 'CurrentCharacter');
       disp(dir) %displays the character that was pressed
end
    switch dir
         case 'w'
          setMotorSpeed(24);
          c=1;
         case'a'
          setSteerDirection(-22);
          c=2;
         case  's'
          setMotorSpeed(-22);
         c=3;
         case 'd'
          setSteerDirection(22);
         c=4;
         case 'e'
          setMotorSpeed(0);    
         c= -1;
        case 'q'
           setMotorSpeed(0);  
         c=5;
        otherwise
         c=0;
    end
end
end