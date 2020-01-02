function Update_Image_Panel(PPA, UIAxis, newImage, dim)

  if nargin < 4
    dim = 3;
  end

  nChild = numel(UIAxis.Children);

  for iChild = 1:nChild
    obj = UIAxis.Children(iChild);
    isLine = isa(obj, 'matlab.graphics.primitive.Line');
    isImage = ~isLine && isprop(obj, 'cdata');

    if isempty(newImage)
      delete(obj);
    elseif isImage% make sure we set the images...
      set(obj, 'cdata', newImage);

      switch dim
        case 1% yz proj
          set(obj, 'xdata', PPA.yPlot);
          set(obj, 'ydata', PPA.zPlot);
        case 2% xz proj
          set(obj, 'xdata', PPA.xPlot);
          set(obj, 'ydata', PPA.zPlot);
        case 3% xy proj
          set(obj, 'xdata', PPA.xPlot);
          set(obj, 'ydata', PPA.yPlot);
      end

      UIAxis.CLim = minmax(newImage); % update colorbar limits
    end

  end

  UIAxis.BackgroundColor = 'white';

end
