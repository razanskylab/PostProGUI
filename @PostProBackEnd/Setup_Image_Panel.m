function Setup_Image_Panel(PPA, UIAxis, isNewData, ~)

  disableDefaultInteractivity(UIAxis);
  UIAxis.Toolbar.Visible = 'off';

  if (nargin < 3)
    isNewData = false;
  end

  axis(UIAxis, 'tight');
  axis(UIAxis, 'image');
  colormap(UIAxis, PPA.GUI.cBars.Value);
  if isempty(UIAxis.Children) || isNewData
    % prepare panel for "normal" xy projection images = most of what we have
    cla(UIAxis); % clear axis, also removes all children
    % colorbar(UIAxis);
    imagesc(UIAxis,nan(1));

    % init to zero but set correct size, so we can just update the cdata
    % imagesc handle can always be accessed as:
    % i = UIAxis.Children(1);
    % set(i,'cdata',zeros(2000));
  else

  end

  UIAxis.BackgroundColor = 'white';

end
