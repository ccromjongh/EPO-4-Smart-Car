function [SteerDirection,Time] = Diameter2SteerDirection(Diameter)
    % When the diameter is 0, just go straight. Infinity is not a very nice number
    if (Diameter == 0)
        SteerDirection = 5;
        Time = 0.109;
    % Negative diameter means steering left
    elseif (Diameter > 0)
        SteerDirection = -1.806e+10*exp(-15*Diameter) + -70.74*exp(-0.481*Diameter);
        Time = 0.11;
    % Positive means steering right
    else
        SteerDirection = 288.6*exp(1.684*Diameter) + 35.29*exp(0.1007*Diameter) +2.1;
        Time = 0.11;
    end
end