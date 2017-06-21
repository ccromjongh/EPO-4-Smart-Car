function [SteerDirection,Time] = Diameter2SteerDirection(Diameter, Twindex)
    % When the diameter is 0, just go straight. Infinity is not a very nice number
    if Twindex < 10
            Time = 0.6 - 0.19*log(x);
        else
            Time = 0.15;
    end
    if (Diameter == 0)
        SteerDirection = 6;
                
    % Negative diameter means steering right
    elseif (Diameter > 0)
        SteerDirection = -1.806e+10*exp(-15*Diameter) + -70.74*exp(-0.481*Diameter);
%         Time = 0.109;
    % Positive means steering left
    else
        SteerDirection = 288.6*exp(1.684*Diameter) + 35.29*exp(0.1007*Diameter) +2.1;
%         Time = 0.117;
    end
end