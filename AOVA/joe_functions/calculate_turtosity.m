function [turtosity] = calculate_turtosity(vesArcLength,vesDistances)
  % Tortuosity defined as arc-chord ratio:
  % the ratio of the length of the curve to the distance between the ends of it
  % this is the simplest possbile definition of turtosity, which should be more
  % than OK for our usecase.
  turtosity = vesArcLength./vesDistances;
end
