    function Med_Filt_Volume(PPA)
      % Med_Filt_Volume  3d median filtering using medfilt3
      % See also Down_Sample_Volume(), Crop_Volume(),
      try

        if PPA.doVolMedianFilter
          PPA.Start_Wait_Bar('Median filtering volumetric data.');
          statusText = sprintf('Median filtering volumetric data (%i %i %i).', ...
            PPA.volMedFilt(1), PPA.volMedFilt(2), PPA.volMedFilt(3));
          PPA.Start_Wait_Bar(statusText);
          PPA.filtVol = medfilt3(PPA.freqVol, ...
            [PPA.volMedFilt(1), PPA.volMedFilt(2), PPA.volMedFilt(3)]);
          PPA.Stop_Wait_Bar();
        else
          PPA.filtVol = PPA.freqVol;
        end

      catch me
        PPA.Stop_Wait_Bar();
        rethrow(me);
      end

    end
