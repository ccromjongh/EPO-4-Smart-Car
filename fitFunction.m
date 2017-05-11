function [Z, Fit] = fitFunction (timeArr, distArr, max_distance)
    % Fit = fit(timeArr, distArr, 'poly2', 'Robust', 'Bisquare');
    Fit = polyfit(timeArr, distArr, 2);
    Deriv = polyder(Fit);
    totalDistance = max_distance + polyval(Deriv, timeArr)^2/500;

    Fit(end) = Fit(end) - totalDistance;
    rootsR = roots(Fit);
    % Only take real values
    rootsR = rootsR(real(rootsR)>0&imag(rootsR)==0);

    if (~isempty(rootsR))
        if(max(rootsR) > 0.5)
            Z = max(rootsR) - timeArr(end);
        else
            Z = 0;
        end
    else
        Z = 0;
    end
end