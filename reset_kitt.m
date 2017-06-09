KITT.openPort('COM5');

pause(0.1);

KITT.setupBeacon(15000, 3000, 10, '983BD2C4');
KITT.toggleBeacon(true);
pause(0.5);
KITT.toggleBeacon(false);

pause(0.4);

KITT.setupBeacon(20000, 5000, 30, '983BD2C4');

KITT.toggleBeacon(true);
pause(0.5);
KITT.toggleBeacon(false);
