function Apply_Frangi(PPA, unFilt)
  % check if we actually have data to work with
  if nargin == 1
    unFilt = PPA.procProj;
  end
  
  if isempty(unFilt)
    return;
  end
  
  try
    unFilt = normalize(unFilt);
    PPA.ProgBar = uiprogressdlg(PPA.GUI.UIFigure, 'Title', 'Frangi Filtering ');

    sensitivity = PPA.GUI.SensitivityEditField.Value;
    inverted = ~PPA.GUI.InvertedCheckBox.Value;

    % scalesToUse in micrometer
    sigmas = sort(PPA.scalesToUse);
    % convert to pixel (rounding done later in for loop) 
    sigmas = sigmas ./ PPA.dR;

    nSigmas = length(sigmas);

    sigmas = double(sigmas);
    PPA.frangiFilt = zeros(size(unFilt), 'like', unFilt); % filtered image
    PPA.frangiScales = zeros([size(unFilt) nSigmas], 'like', unFilt); % fitlered scales

    for iScale = 1:nSigmas
      PPA.ProgBar.Value = iScale ./ nSigmas; % update progress bar
      PPA.ProgBar.Message = sprintf('Filtering scale %i/%i...', iScale, nSigmas);
      iSigma = sigmas(iScale) / 6;
      iFilt = imgaussfilt(unFilt, iSigma, 'FilterSize', 2 * ceil(3 * iSigma) + 1);
      iFilt = builtin("_fibermetricmex", iFilt, sensitivity, inverted, iSigma);
      PPA.frangiScales(:, :, iScale) = iFilt;
    end
    close(PPA.ProgBar);

    % combine frangi filtered and original image
    PPA.Update_Frangi_Combo(unFilt);
    
    % plot scale,  etc...
    PPA.Plot_Frangi();

  catch me
    close(PPA.ProgBar);
    rethrow(me);
  end

end
