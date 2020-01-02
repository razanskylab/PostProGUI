function [] = plot_vessel_edges(vessel_list,color,lineWidth)
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
  fun = @(x) cat(1, x, [nan, nan]);
  side1 = cellfun(fun, {vessel_list.side1}, 'UniformOutput', false);
  side2 = cellfun(fun, {vessel_list.side2}, 'UniformOutput', false);
  side1 = cell2mat(side1');
  side2 = cell2mat(side2');
  % line(side1(:,2), side1(:,1),'--', 'Color', color,'linewidth', lineWidth);
  % line(side2(:,2), side2(:,1),'--', 'Color', color,'linewidth', lineWidth);
  line(side1(:,2), side1(:,1),'LineStyle','--', 'Color', color,'linewidth', lineWidth);
  line(side2(:,2), side2(:,1),'LineStyle','--', 'Color', color,'linewidth', lineWidth);
end
