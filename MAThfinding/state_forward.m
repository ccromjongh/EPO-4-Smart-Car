function [loc orient ] = state_forward(movement)
%check for forward movement
if FIELD(orient) ~= 0
    movement = 2;
else
    movement = 0;
end

end

