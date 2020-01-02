function [] = Show(F)
  % handle figures
  if F.verboseOutput
    fprintf('[Frangi] Plotting frangi filtered images...');
  end
  figure() % always create scales in seperate figure

  % find number of scales for plotting
  [m,n] = find_subplot_dividers(F.nScales+1); % +1 to always show orig raw image

  % always plot raw image that was used for filtering
  subplot_tight(m,n,1);
    montage = imfuse(F.raw,F.filt,'montage');
    imshow(montage);
  title('Unfiltered vs filtered raw image');

  for iPlot = 1:F.nScales
    % fprintf(['    Plotting frangi scale ', num2str(iPlot) , '...\n']);
    filtImage = F.filtScales(:,:,iPlot);
    filtImage = normalize(filtImage);
    filtImage = adapthisteq(filtImage,'Distribution',F.claheDistr,'NBins',F.claheNBins,...
      'ClipLimit',F.claheLim,'NumTiles',F.claheNTiles);

    [~,montage] = im_overlay(F.raw,filtImage);
    subplot_tight(m,n,iPlot+1);
      imshow(montage);
      % don't create new figures for each scale, we have subplots for that
      % but we have to change the F.newFigPlotting settings as it's used in Overlay_Mask
      title(sprintf('Scale: %i',iPlot));
  end

  if F.verboseOutput
    done();
  end
end
