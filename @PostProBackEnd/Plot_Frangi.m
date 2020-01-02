function Plot_Frangi(PPA, scaleOnly, selectedScale)
  try
    if nargin == 1
      scaleOnly = false;
      selectedScale = 1;
    elseif nargin == 2
      selectedScale = 1;
    end

    if ~scaleOnly
      plotAx = PPA.GUI.imFrangiFiltIn.Children(1);
      set(plotAx, 'cdata', PPA.preFrangi);

      plotAx = PPA.GUI.imFrangiScale.Children(1);
      set(plotAx, 'cdata', squeeze(PPA.frangiScales(:, :, selectedScale)));

      plotAx = PPA.GUI.imFrangiFilt.Children(1);
      set(plotAx, 'cdata', PPA.frangiFilt);

      plotAx = PPA.GUI.imFrangiCombined.Children(1);
      set(plotAx, 'cdata', PPA.frangiCombo);
    else
      plotAx = PPA.GUI.imFrangiScale.Children(1);
      set(plotAx, 'cdata', squeeze(PPA.frangiScales(:, :, selectedScale)));
    end

  catch me
    rethrow(me);
  end

end
