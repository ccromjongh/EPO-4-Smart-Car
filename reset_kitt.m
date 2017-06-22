KITT.closePort();
%pause(0.5);
KITT = testClass;
KITT.openPort('COM3');

pause(0.5);

KITT.setupBeacon(10000, 5000, 10, '983BD2C4');
KITT.toggleBeacon(true);
pause(1);

KITT.toggleBeacon(false);
KITT.setupBeacon(15000, 5000, 10, '983BD2C4');
KITT.toggleBeacon(true);
pause(1);
KITT.toggleBeacon(false);


% KITT.toggleBeacon(false);
% KITT.setupBeacon(18000, 4500, 10, '983BD2C4');
% KITT.toggleBeacon(true);
% pause(1);
% 
% KITT.toggleBeacon(false);
% KITT.setupBeacon(20000, 5000, 10, '983BD2C4');
% KITT.toggleBeacon(true);
% pause(1);
% 
% KITT.toggleBeacon(false);
% KITT.setupBeacon(20000, 5000, 30, '983BD2C4');
% KITT.toggleBeacon(true);
% pause(1);
% 
% KITT.toggleBeacon(false);
