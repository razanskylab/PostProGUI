function Plot(F,varargin)
  % simple default plotting of xy maps or xy vs filt maps3
  % plus option to plot with histograms
  
  if nargin == 1 || isempty(varargin)
    whatPlot = 1; %
  else
    whatPlot = varargin{1};
  end

  if (whatPlot == 3) && isempty(F.filt)
    short_warn('You need to apply the filter before plotting filt image!');
    short_warn('Plotting raw image instead so you have sth. to look at!');
    whatPlot = 2;
  end

  switch whatPlot
  case 1
    if F.showHisto
      subplot(1,3,[1 2]);
        imagescj(F.filt,F.colorMap);
        xlabel('x-axis (idx)');
        ylabel('y-axis (idx)');
        title('Filtered Map');
      subplot(1,3,3);
        pretty_hist(F.filt);
        title('Filtered Map Histogram');
    else
      imagescj(F.filt,F.colorMap);
      xlabel('x-axis (idx)');
      ylabel('y-axis (idx)');
      title('Filtered Map');
    end
  case 2 % show raw/unfiltered image with or w/o histograms
    if F.showHisto
      subplot(1,3,[1 2]);
        imagescj(F.xy,F.colorMap);
        xlabel('x-axis (idx)');
        ylabel('y-axis (idx)');
        title('XY-Map');
      subplot(1,3,3);
        pretty_hist(F.xy);
        title('XY-Map Histogram');
    else
      imagescj(F.xy,F.colorMap);
      xlabel('x-axis (idx)');
      ylabel('y-axis (idx)');
      title('XY-Map');
    end
  case 3
    if F.showHisto
      % plot raw images
      subplot(2,3,[1 2]);
        imagescj(F.xy,F.colorMap);
        xlabel('x-axis (idx)');
        ylabel('y-axis (idx)');
        title('XY-Map');
      subplot(2,3,3);
        pretty_hist(F.xy);
        title('XY-Map Histogram');
      % plot filt images
      subplot(2,3,[4 5]);
        imagescj(F.filt,F.colorMap);
        xlabel('x-axis (idx)');
        ylabel('y-axis (idx)');
        title('Filtered Map');
      subplot(2,3,6);
        pretty_hist(F.filt);
        title('Filtered Map Histogram');
    else
      subplot(1,1,1);
        imagescj(F.xy,F.colorMap);
        xlabel('x-axis (idx)');
        ylabel('y-axis (idx)');
        title('XY-Map');
      subplot(1,1,2);
        imagescj(F.filt,F.colorMap);
        xlabel('x-axis (idx)');
        ylabel('y-axis (idx)');
        title('Filtered Map');
    end
  end % end of switch statement
  figure(gcf);
end
