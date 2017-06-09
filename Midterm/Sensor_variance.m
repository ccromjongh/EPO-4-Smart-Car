comport = '\\.\COM3';       % Name of the port to be opened
re_open_port = true;        % Close and open port

% Create instance of control class
KITT = testClass;

if (re_open_port)
    KITT.openPort(comport);
end

measurements = zeros(2, 200);

for i = 1:200
    KITT.getDistance();
    measurements(1, i) = KITT.leftDistance;
    measurements(2, i) = KITT.rightDistance;
    disp(num2str(i));
    pause(0.2);
end

varLeft = var(measurements(1, :));
varRight = var(measurements(2, :));