JSON = fileread('field_K.json');
field_data = jsondecode(JSON);
clear JSON;

start_location = [-2 -2];
start_angle = 0;
final_location = [2 2];

location = start_location;
while true
[Hdist, Fs] = RecordLive(true, 5);
[x, y, z] =  tdoa2(transpose([field_data.mics.x; field_data.mics.y; field_data.mics.z ]), Hdist,Fs);
% append location 
location = [location; [x y]];

% Get current diameter from c++ routing
Diameter = main(start_location(1), start_location(2), start_angle, final_location(1), final_location(2));
 
% Use diameter to set direction
dir = Diameter2SteerDirection(Diameter);
KITT.setSteerDirection(dir);

% eventueel snelheid gaan meten en variabel maken, zodat de auto zowel in
% de bochten als rechtdoor even snel gaat
KITT.setMotorSpeed(26);

%if within 15 cm of final location break
if abs(final_location - location(end)) < 0.15
    break; 
end
end
