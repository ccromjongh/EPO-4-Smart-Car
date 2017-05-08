clear variables;
%% Script settings
comport = '\\.\COM7';       % Name of the port to be opened
re_open_port = true;       % Close and open port

% Create instance of control class
KITT = testClass;

if (re_open_port)
    KITT.openPort(comport);
end

KITT.getStatus();   % Get status from KITT
KITT.status         % Print status message

%% Delay test
KITT.getDistance();

leftDistance = KITT.leftDistance;   % Initial left sensor distance
rightDistance = KITT.rightDistance; % Initial right sensor distance
request = 0;                        % Amount of requests send to KITT
tic
KITT.setMotorSpeed(30);
KITT.setSteerDirection(4);
while (true)
    KITT.getDistance();
    NewleftDistance = KITT.leftDistance;
    NewrightDistance = KITT.rightDistance;
    if ((NewleftDistance < leftDistance) || (NewrightDistance < rightDistance))
        delay_time = toc;
        break;
    else
        request = request + 1;
    end
end

KITT.setMotorSpeed(0);
