function [Z, Fit] = fitFunction (timeArr, distArr, max_distance)
    % Fit = fit(timeArr, distArr, 'poly2', 'Robust', 'Bisquare');
    Fit = polyfit(timeArr, distArr, 2);
    
    % Calculate speed using derivative
    Deriv = polyder(Fit);
    speed = polyval(Deriv, timeArr(end));
    totalDistance = max_distance + speed^2/900;
    fprintf("totalDistance = %.2f\tbreakDist = %.2f\tspeed = %.2f\n", totalDistance, (totalDistance - max_distance), speed);

    Fit2 = Fit;
    Fit2(end) = Fit2(end) - totalDistance;
    fitRoots = roots(Fit2);
    % Only take real values
    fitRoots = fitRoots(real(fitRoots)>0&imag(fitRoots)==0);

    % Only if roots are found, should Z be calculated
    if (~isempty(fitRoots))
        if(max(fitRoots) > 0.5 && speed < 0 && speed > -200)
            Z = max(fitRoots) - timeArr(end);
        else
            Z = 0;
        end
    else
        Z = 0;
    end
end