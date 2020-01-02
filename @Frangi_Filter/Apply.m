function [] = Apply(F)
  t1 = tic;
  if F.verboseOutput
    fprintf('[Frangi.Apply] Filtering:\n');
  else
    fprintf('[Frangi.Apply] Filtering...');
  end

  nScales = numel(F.allScales);

  % scale ranges are influenced by actual physical size of image
  % i.e. by the pixel/mm aka pixeldensity
  % calculate pixel density [defined as pixels/mm] and correct scale range using it!
  % we store the old frangi scale range as class property and use effective values here
  % otherwise we get changing frangi settings if we run it multiple times.

  % Normalize
  F.filt = normalize(F.raw);

  if F.verboseOutput
    fprintf('   Pixel size = %2.1f microm\n', F.dR*1e3);
    fprintf('   Using %i scales (from %i to %i)\n', F.nScales,F.startScale,...
      F.stopScale);
    fprintf('   Using %i effective scales (from %2.1f to %2.1f)\n',...
      nScales, F.allEffectiveScales(1), F.allEffectiveScales(end));
  end

  % Perform actual frangi filtering
  if F.verboseOutput
    fprintf('   Perform actual frangi filtering...');
  end

  F.Filter_2D_fast();
  F.filt = normalize(F.filt);

  % normalize again to be safe
  if F.verboseOutput
    fprintf('completed in %2.1f s.\n',toc(t1));
  else
    done(toc(t1));
  end

  % show seperate frangi scales in their own figure if F.frangiShowScales
  if F.showScales
    F.Show();
  end

  notify(F,'FiltUpdated'); % used to update Maps class
end
