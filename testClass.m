classdef testClass<handle
    properties
        currentPortName = ''
        portIsOpen = false
        status = ''
        leftDistance = 999
        rightDistance = 999
        batteryVoltage = 0
        speed = 15
        direction = 0
    end
    
    methods
        % Function to open serial port to communicate with KITT
        % Param: `comport`, string
        function obj = openPort (obj, comport)
%             try
%                 EPOCommunications('close');                 % If port was open, close it first
%                 pause(0.5);
%             catch
% 
%             end
            pause(0.1);
            obj.portIsOpen = false;
            result = EPOCommunications('open', comport);    % Open connection
            if (result == 0)
                error('Port in use or not available');      % Throw error
            end
            obj.portIsOpen = true;
            obj.currentPortName = comport;
        end
        
        % Function to close serial port when the job is done
        function obj = closePort (obj)
            EPOCommunications('close');     % Close connection
            obj.currentPortName = '';
            obj.portIsOpen = false;
        end
        
        % Function to set up the audio beacon parameters of KITT
        % Param:
        % `Timer0` see manual P39 (43/87), carrier frequency
        % `Timer1`  ^ , bit frequency for modulating code on carrier
        % `Timer3`  ^ , repeat frequency of the ref_signal
        function obj = setupBeacon(obj, Timer0, Timer1, Timer3, SecretCode)
            EPOCommunications('transmit', ['F' num2str(Timer0)]);	% Timer0, carrier frequency
            java.lang.Thread.sleep(20);
            EPOCommunications('transmit', ['B' num2str(Timer1)]);	% Timer1, bit frequency
            java.lang.Thread.sleep(20);
            R_count = Timer1/Timer3;
            EPOCommunications('transmit', ['R' num2str(R_count)]);	% Set the repetition count
            java.lang.Thread.sleep(20);
            EPOCommunications('transmit', ['C0x' SecretCode]);      % Set the audio code
            java.lang.Thread.sleep(20);
        end
        
        function obj = toggleBeacon(obj, toggle)
           if (toggle)
               EPOCommunications('transmit', 'A1');
           else
               EPOCommunications('transmit', 'A0');
           end
        end
        
        % Function to set the steering direction of KITT
        % Param: `direction` between [-50, 50]
        function obj = setSteerDirection (obj, direction)
            direction = int16(direction);                           % Make sure value is integer
            if (direction < -50)
                error('Speed too low. %d < -50', direction);        % Value too low
            elseif (direction > 50)
                error('Speed too high. %d > 50', direction);        % Value too high
            end
            obj.direction = direction;
            direction = direction + 150;
            EPOCommunications('transmit', ['D' num2str(direction)]);    % Write value
        end
        
        % Function to set the forward speed of KITT
        % Param: `speed` between [0, 30]
        function obj = setMotorSpeed (obj, speed)
            speed = int16(speed);
            if (speed < 0)
                error('Speed too low. %d < 0', speed);
            elseif (speed > 30)
                error('Speed too high. %d > 30', speed);
            end
            obj.speed = speed;
            speed = speed + 135;
            EPOCommunications('transmit', ['M' num2str(speed)]);
        end
        
        % Function to get the status string from KITT
        function obj = getStatus(obj)
            obj.status = EPOCommunications('transmit', 'S');        % request status string
        end
        
        % Function to get the data from the distance sensors,
        % and parse it to obtain numerical values
        function obj = getDistance(obj)
            distString = EPOCommunications('transmit', 'Sd');       % request distance status string
            distArr = strsplit(distString, '\n');                   % Split string by \n char
            
            % Safeguard to filter out wrong transmissions
            if (length(distArr) >= 3)
                leftStr = distArr{1};                                   % Get Left Dist. string
                rightStr = distArr{2};                                  % Get Right Dist. sting
                obj.leftDistance = str2double(leftStr(4:end));          % Extract number
                obj.rightDistance = str2double(rightStr(4:end));        % Extract number
                if (obj.leftDistance < 10); obj.leftDistance = 999; end;
                if (obj.rightDistance < 10); obj.rightDistance = 999; end;
            end
        end
        
        % Function to het the battery voltage as a numerical value
        function obj = getBatteryVOltage(obj)
            battString = EPOCommunications('transmit', 'Sv');       % request battery status string
            numStr = regexp(battString, '[0-9]+.[0-9]', 'match');
            obj.batteryVoltage = str2double(numStr);                % Extract number
        end
    end
end