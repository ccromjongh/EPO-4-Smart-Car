comport = '\\.\COM3';       % Name of the port to be opened
re_open_port = true;        % Close and open port

% Create instance of control class
KITT = testClass;

if (re_open_port)
    KITT.openPort(comport);
end

for i = 1:200
    KITT.getDistance();
    sprintf('%d\t%d', num2str(KITT.leftDistance), num2str(KITT.rightDistance));
    pause(0.1);
end

KITT.closePort();