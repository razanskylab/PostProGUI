function [] = plot_vessel_centerlines(vessel_list,color,lineWidth)
  % Somewhat convoluted but improves painting speed by rather
  % a lot (perhaps 5-10 times), and also improves toggling
  % visible / invisible speed.
  % Because centre lines and vessel edges will either all be
  % shown or none at all, each can be plotted as a single
  % 'line' object rather than separate objects for each
  % vessel.  To do so, they need to be converted into single
  % vectors, with NaN values where points should not be
  % connected (i.e. between vessels).
  % Paint centre lines
  if nargin < 3
    lineWidth = 2;
    color = Colors.PureRed;
  elseif nargin < 2
    color = Colors.PureRed;
  end
  fun = @(x) cat(1, x, [nan, nan]);
  temp = cellfun(fun, {vessel_list.centre}, 'UniformOutput', false);
  cent = cell2mat(temp');
  line(cent(:,2), cent(:,1),'LineStyle','-','Color', color,'linewidth', lineWidth);
end
