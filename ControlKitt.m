% Load playfield data
JSON = fileread('field_K.json');
field_data = jsondecode(JSON);
clear JSON;

r1 = 0.1;

% Set start and end location
start_location = [-2 -2];
start_angle = 0;
final_location = [2 2];

location = start_location;

while true
    % Record audio from KITT's beacon and find the propagation delay
    [Hdist, Fs] = RecordLive(true, 5);
    
    % Execute TDOA script to find KITT's location
    [x, y, z] =  tdoa2([field_data.mics.x; field_data.mics.y; field_data.mics.z ]', Hdist, Fs);
    
    % Append location to history
    location = [location; [x y]];

    % Get current diameter from c++ routing
    [x_nav, y_nav, ang_nav] = main(start_location(1), start_location(2), start_angle, final_location(1), final_location(2));
    radius_arr = 0.5 * r1 * tan(0.5 * (pi - ang_nav));
    Diameter = 2*radius_arr(1);

    % Use diameter to set direction
    dir = Diameter2SteerDirection(Diameter);
    KITT.setSteerDirection(dir);

    % Eventueel snelheid gaan meten en variabel maken, zodat de auto zowel in
    % de bochten als rechtdoor even snel gaat
    KITT.setMotorSpeed(26);

    % If within 15 cm of final location, break
    if abs(final_location - location(end)) < 0.15
        KITT.setMotorSpeed(15);
        break; 
    end
end
