function [] = plot_rainbow_centerlines(VesselList,colormap,lineWidth)
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
  nVessels = numel(VesselList);
  if nargin < 3
    lineWidth = 2;
    colormap = jet(nVessels);
  elseif nargin < 2
    colormap = jet(nVessels);
  end
  for iVes = 1:nVessels
    line(VesselList(iVes).centre(:,2), VesselList(iVes).centre(:,1), 'Color', colormap(iVes,:),'linewidth', lineWidth);
  end
end
