    % remove spot noise  -------------------------------------------------------------
    function [filtImage, filtDepth] = Remove_Spots(IMF, rawDepth)
      IMF.VPrintF('[IMF] Removing spot noise...');
    %   minmaxPre = minmax(IMF.filt); % get orignal min max
    %   IMF.filt = normalize(IMF.filt);

      % perform actual filtering
      [IMF.filt, filtDepth] = remove_spot_noise(IMF.filt, IMF.spotLevels, rawDepth);

    %   IMF.filt = normalize(IMF.filt); % normalize again, then restore orig scale
    %   IMF.filt = reverse_normalize(IMF.filt, minmaxPre); % restore old max values
      filtImage = IMF.filt;
    end
