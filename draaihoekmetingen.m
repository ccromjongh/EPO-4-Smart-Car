%KITT = testClass;

length = 0.345;
width = 0.32;
diameter = 1.65;
angle = atan(2*(length/(diameter-width)));
ang_360 = 360 * angle / (2*pi);

%KITT.setMotorSpeed(26);
%-----------------------------------------
%KITT.setSteerDirection(50);  % d = 165 cm; t = 3.0 s; MS = 26
%-----------------------------------------
%KITT.setSteerDirection(45);  % d = 167 cm; t = 2.9 s; MS = 26
%KITT.setSteerDirection(40);  % d = 192 cm; t = 3.0 s; MS = 26
%KITT.setSteerDirection(35);  % d = 226 cm; t = 3.1 s; MS = 26
%KITT.setSteerDirection(30);  % d = 273 cm; t = 3.5 s; MS = 26
%KITT.setSteerDirection(25);  % d = 355 cm; t = 3.9 s; MS = 26
%KITT.setSteerDirection(20);  % d = 570 cm; t = 6.0 s; MS = 26

%KITT.setSteerDirection(-50); % d = 140 cm; t = 2.5 s; MS = 28
%KITT.setSteerDirection(-45); % d = 144 cm; t = 2.5 s; MS = 28
%KITT.setSteerDirection(-40); % d = 144 cm; t = 2.7 s; MS = 27
%-----------------------------------------
%KITT.setSteerDirection(-35); % d = 160 cm; t = 2.8 s; MS = 27
%-----------------------------------------
%KITT.setSteerDirection(-30); % d = 180 cm; t = 2.8 s; MS = 27
%KITT.setSteerDirection(-25); % d = 210 cm; t = 3.0 s; MS = 26
%KITT.setSteerDirection(-20); % d = 245 cm; t = 3.1 s; MS = 26
%KITT.setSteerDirection(-15); % d = 325 cm; t = 3.4 s; MS = 26
%KITT.setSteerDirection(-10); % d = 440 cm; t = 3.7 s; MS = 26

%pause(3.7);

%KITT.setMotorSpeed(15);
