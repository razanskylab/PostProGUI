function [figHandle] = Plot(IMF, plotWhat)

  if nargin < 2
    plotWhat = 'default';
  end

  figHandle = figure(gcf); clf;
  ax = gca;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % switch between all the possible plotting options
  tic; % used for all the IMF.Done();

  switch plotWhat
    case 'default'
      % close(gcf);
      IMF.Plot('mip');

    case 'all'% mostly used for testing, plots everything this function can plot!

    case 'mip'
      imagesc(ax, IMF.x, IMF.y, IMF.filt);
      axis(ax, 'tight');
      axis(ax, 'image');
      colormap(ax, IMF.colorMap);
      colorbar(ax);

    otherwise
      IMF.PrintF('Unknown plot option '' %s''!\n', plotWhat);
  end

  drawnow limitrate; % show latest plot, slow when in for loop!!!
  IMF.figureHandle = figHandle;

end
