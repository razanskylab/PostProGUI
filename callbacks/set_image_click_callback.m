function set_image_click_callback(UIAxis,PPA)
  % checks for acutal images in a uiaxis and set's their click function
  % lines etc. are ignored
  nChild = numel(UIAxis.Children);

  for iChild = 1:nChild
    obj = UIAxis.Children(iChild);

    if isa(obj, 'matlab.graphics.primitive.Image')
      obj.ButtonDownFcn = {@postpro_image_click, PPA}; %PPA will be passed to the callback
    end

  end

end
