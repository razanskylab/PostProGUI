function Freq_Filt_Volume(PPA)
  % Freq_Filt_Volume performs time-domain filtering of A-scans
  %   also permutes volume data from [zxy] to [xyz]
  %
  % See also Med_Filt_Volume(), Crop_Volume()

  try

    if PPA.VolGUI.FreqFiltCheck.Value
      PPA.Start_Wait_Bar(PPA.VolGUI,'Frequency filtering volumetric data.');

      % get actual df based on original dt
      PPA.FreqFilt.df = (1 ./ PPA.dt) * 1e-6; % filt freq. define in MHz as well
      if PPA.doVolDownSampling
        % correct for downsampling
        PPA.FreqFilt.df = PPA.FreqFilt.df ./ PPA.volSplFactor(2);
      end

      maxHighPassFreq = PPA.FreqFilt.df ./ 2 - 1; % good old nyquist...

      if (PPA.VolGUI.freqHigh.Value > maxHighPassFreq)
        PPA.VolGUI.freqHigh.Value = maxHighPassFreq;
        PPA.Start_Wait_Bar(PPA.VolGUI,'Reduced upper bandpass frequency to allowed value!');
        short_warn('Reduced upper bandpass frequency to allowed value!');
      end

      % transfer settings to filter class
      if strcmp(PPA.VolGUI.filtType.Value, 'highpass')
        PPA.FreqFilt.freq = PPA.VolGUI.freqLow.Value;
        filtFreqStr = sprintf('   Highpass aboce %2.0f MHz (order=%i)', ...
          PPA.VolGUI.freqLow.Value, PPA.VolGUI.filtOrder.Value);
      elseif strcmp(PPA.VolGUI.filtType.Value, 'bandpass')
        PPA.FreqFilt.freq = [PPA.VolGUI.freqLow.Value PPA.VolGUI.freqHigh.Value];
        filtFreqStr = sprintf('   Bandpass between %02.0f and %02.0f MHz (order=%i)', ...
          PPA.VolGUI.freqLow.Value, PPA.VolGUI.freqHigh.Value, PPA.VolGUI.filtOrder.Value);
      end

      PPA.FreqFilt.order = PPA.VolGUI.filtOrder.Value;

      if strcmp(PPA.VolGUI.filtDesign.Value, 'butterworth')
        PPA.FreqFilt.filtType = 1;
      elseif strcmp(PPA.VolGUI.filtDesign.Value, 'chebyshev')
        PPA.FreqFilt.filtType = 2;
      end

      % print status update text
      statusText = sprintf('   Type: %s-%s\n%s\n', ...
        PPA.VolGUI.filtDesign.Value, PPA.VolGUI.filtType.Value, filtFreqStr);
      PPA.Update_Status(statusText);

      % Define & plot filter response
      PPA.FreqFilt.Define();
      PPA.FreqFilt.tech = 1; % use faster FiltFiltM
      PPA.FreqFilt.filtMode = '3d'; % make sure we use fast 3d freq. filtering
      PPA.FreqFilt.Plot_Amp(PPA.VolGUI.FiltResponseAx);

      % perform actual filtering and permute in one step
      % (to avoid allocating even more memory...)
      PPA.freqVol = permute(PPA.FreqFilt.Apply_Vol(PPA.cropVol), [2 3 1]);
      PPA.Stop_Wait_Bar();
    else
      % always permute here, to convert to xyz format
      PPA.freqVol = permute(PPA.cropVol, [2 3 1]);
    end

  catch me
    PPA.Stop_Wait_Bar();
    rethrow(me);
  end

end
