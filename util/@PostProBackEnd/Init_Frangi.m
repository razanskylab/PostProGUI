function Init_Frangi(PPA,whichFrangi)
  % Init_Frangi()
  % called before opening Frangi GUI make sure it's up to date...

  if (nargin == 1)
    whichFrangi = 'map';
  end
  try
    switch whichFrangi
    case 'map'
      if isempty(PPA.MapFrangi)
        PPA.MapFrangi = Frangi_Filter();
      end
      PPA.MapFrangi.raw = PPA.procProj;
      PPA.MapFrangi.x = PPA.xPlotIm;
      PPA.MapFrangi.y = PPA.yPlotIm;

      if isempty(PPA.MapFrangi.GUI)
        PPA.MapFrangi.Open_GUI();
      end
    case 'vessel'
      % check if we have a Frangi GUI already...
      if isempty(PPA.VesselFrangi)
        PPA.VesselFrangi = Frangi_Filter();
      end
      PPA.VesselFrangi.raw = PPA.procProj;
      PPA.VesselFrangi.x = PPA.xPlotIm;
      PPA.VesselFrangi.y = PPA.yPlotIm;

      if isempty(PPA.VesselFrangi.GUI)
        PPA.VesselFrangi.Open_GUI();
      end
    end


  catch ME
    PPA.Stop_Wait_Bar();
    rethrow(ME);
  end

end
