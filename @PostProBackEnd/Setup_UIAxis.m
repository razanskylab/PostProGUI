function Setup_UIAxis(PPA, UIAxis)
  disableDefaultInteractivity(UIAxis);
  UIAxis.Toolbar.Visible = 'off';
  axis(UIAxis, 'tight');
  axis(UIAxis, 'image');
  colormap(UIAxis, PPA.MasterGUI.cBars.Value);
  cla(UIAxis); % clear axis, also removes all children
  imagesc(UIAxis, nan(1));

end
