function Update_Frangi_Combo(PPA,unFilt)
  % PPA.Update_Frangi_Combo() Combine selected frangi scales and apply to image
  %
  % Needs already calculated PPA.frangiScales, then used the max-amp projection
  % of those to form frangi filtered image...
  %
  % See also Update_Frangi_Scales(), Apply_Frangi(), Apply_Image_Processing()

  % only take selected scales into account
  selectedScales = [PPA.GUI.UITable.Data{:, 2}];
  PPA.frangiFilt = squeeze(max(PPA.frangiScales(:, :, selectedScales), [], 3));

  % combines Frangi & processes map to "filtered image";
  % TODO have different options on how to do this
  PPA.frangiCombo = normalize(unFilt) .* PPA.frangiFilt;

  % use image guided filtering here to combine raw and frangi!
  % we either use the frangi filtered image as our guide image
  % if PPA.GUI.FrangiGuidedCheckBox.Value
  %   % calculate frangi filtered image if we don't have one already...
  %   if isempty(PPA.frangiFilt)
  %     PPA.Apply_Frangi(PPA.IMF.filt);
  %   end

  %   PPA.IMF.Guided_Filtering(PPA.frangiFilt);
  %   % or we use the image itself...
  % end

end
