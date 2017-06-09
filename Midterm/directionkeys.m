%direction keys
function directionkeys()

c=0;
dir = '0';
% Create instance of control class
KITT = testClass;
while  c <= 4;
w = waitforbuttonpress;
if w
       dir = get(gcf, 'CurrentCharacter');
       disp(dir) %displays the character that was pressed
end
    switch dir
         case 'w'
          KITT.setMotorSpeed(24);
          c=1;
         case'a'
          KITT.setSteerDirection(-22);
          c=2;
         case  's'
          KITT.setMotorSpeed(6);
         c=3;
         case 'd'
          KITT.setSteerDirection(22);
         c=4;
         case 'e'
          KITT.setMotorSpeed(0);    
         c= -1;
        case 'q'
           KITT.setMotorSpeed(0);  
         c=5;
        otherwise
         c=0;
    end
end
end