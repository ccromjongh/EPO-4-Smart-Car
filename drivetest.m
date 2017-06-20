angs = [0,0,0,0,0,0,0,0,0,0,0,0,1.65,1.65,1.65,1.65,1.65,1.65,1.65,1.65,1.65,1.65,1.65,1.65,1.65,0,0];
KITT = testClass;

% KITT.openPort('//./COM5')
KITT.setMotorSpeed(26);
for i = 1:length(angs)
    tic;
    [dia,t] = Diameter2SteerDirection(angs(i));
    
    while toc < t
        KITT.setSteerDirection(dia);
    end
end
KITT.setMotorSpeed(0);pause(0.3);KITT.setMotorSpeed(15);