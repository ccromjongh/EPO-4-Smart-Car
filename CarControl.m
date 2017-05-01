classdef CarControl<handle
    properties
        currentPortName = ''
        portIsOpen = false
        property = 0
        % Put stuff here
    end
    
    methods (Static = true)
%         function obj = CarControl()
%             obj.currentPortName = '';
%             obj.property = 137.235;
%             % Fun initialization
%         end
        
        % Function to open serial port to communicate with KITT
        % Param: `comport`, string
        function obj = openPort (obj, comport)
            if (~strcmp(obj.currentPortName, comport))          % Only act if string is different
                EPOCommunications('close');                     % If port was open, close it first
                obj.portIsOpen = false;
                result = EPOCommunications('open', comport);    % Open connection
                if (result == 0)
                    error('Port in use or not available');      % Throw error
                end
                obj.portIsOpen = true;
                obj.currentPortName = comport;
            end
        end
        
        % Function to close serial port when the job is done
        function obj = closePort (obj)
            EPOCommunications('close');     % Close connection
            obj.currentPortName = '';
            obj.portIsOpen = false;
            obj.property = 287432.2365;
        end
        
        % Function to set up the audio beacon parameters of KITT
        % Param:
        % `Timer0` see manual P39 (43/87), carrier frequency
        % `Timer1`  ^ , bit frequency for modulating code on carrier
        % `Timer3`  ^ , repeat frequency of the ref_signal
        function setupBeacon(Timer0, Timer1, Timer3, SecretCode)
            EPOCommunications('transmit', ['F' num2str(Timer0)]);	% Timer0, carrier frequency
            EPOCommunications('transmit', ['B' num2str(Timer1)]);	% Timer1, bit frequency
            R_count = Timer1/Timer3;
            EPOCommunications('transmit', ['R' num2str(R_count)]);	% Set the repetition count
            EPOCommunications('transmit', ['C0x' SecretCode]);      % Set the audio code
        end
        
        % Function to set the steering direction of KITT
        % Param: `direction` between [-50, 50]
        function setSteerDirection (direction)
            direction = int8(direction);                            % Make sure value is integer
            if (direction < -50)
                error('Speed too low. %d < -50', direction);        % Value too low
            elseif (speed > 50)
                error('Speed too high. %d > 50', direction);        % Value too high
            end
            EPOCommunications('transmit', ['D' num2str(direction+150)]);	% Write value
        end
        
        % Function to set the forward speed of KITT
        % Param: `speed` between [0, 30]
        function setMotorSpeed (speed)
            speed = int8(speed);
            if (speed < 0)
                error('Speed too low. %d < 0', speed);
            elseif (speed > 30)
                error('Speed too high. %d > 30', speed);
            end
            EPOCommunications('transmit', ['M' num2str(speed+135)]);
        end
        
        function status = getStatus()
            status = EPOCommunications('transmit', 'S'); % request status string
        end
    end
end