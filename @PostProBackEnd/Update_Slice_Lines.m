function Update_Slice_Lines(PPA)
  % Update_Slice_Lines
  % plots slice lines (center solid + 2 dashed) indication xy slice locations

  
  PPA.VolGUI.SliceWidthEditField.Enable = true;
  sliceWidth = PPA.VolGUI.SliceWidthEditField.Value; % convert from micron to mm
  ctrPos = PPA.lineCtr;

  % find plot positions for lines and plot them
  xCtr = ctrPos(1);
  yCtr = ctrPos(2);
  uiAx = PPA.VolGUI.FiltDisp;
  xMinMax = minmax(PPA.xPlot);
  yMinMax = minmax(PPA.yPlot);
  horLineX = [xMinMax(1), xMinMax(2)];
  horLineY = [yCtr, yCtr];
  vertLineX = [xCtr, xCtr];
  vertLineY = [yMinMax(1) yMinMax(2)];

  PPA.HorLine = Update_Line(PPA.HorLine, horLineX, horLineY, [0 sliceWidth./2]);
  PPA.VertLine = Update_Line(PPA.VertLine, vertLineX, vertLineY, [sliceWidth./2 0]);

  % find corresponding part of the volume to get slices from
  xRange = [xCtr - sliceWidth ./ 2, xCtr + sliceWidth ./ 2]; % in mm
  yRange = [yCtr - sliceWidth ./ 2, yCtr + sliceWidth ./ 2]; % in mm
  % convert mm range to idx
  [~, nearestIdx] = find_nearest(xRange, PPA.xPlot); % find idx corresponding to
  xRange = nearestIdx(1):nearestIdx(2);
  [~, nearestIdx] = find_nearest(yRange, PPA.yPlot); % find idx corresponding to
  yRange = nearestIdx(1):nearestIdx(2);

  xzSlice = PPA.procVol(:, yRange, :);
  xzSlice = squeeze(max(xzSlice, [], 2));
  xzSlice = imrotate(xzSlice, -90);

  yzSlice = PPA.procVol(xRange, :, :);
  yzSlice = squeeze(max(yzSlice, [], 1));
  yzSlice = imrotate(yzSlice, -90);

  PPA.xzSlice = xzSlice;
  PPA.yzSlice = yzSlice;

  function lines = Update_Line(lines, xData, yData, offset)

    if ~isempty(lines)
      ctrHandle = lines.ctrHandle;
      upHandle = lines.upHandle;
      lowHandle = lines.lowHandle;
    end

    if ~exist('ctrHandle') ||~isvalid(ctrHandle)
      ctrHandle = line(uiAx, xData, yData, 'Color', [1 1 1], 'LineWidth', 0.25);
      upHandle = line(uiAx, xData + offset(1), yData + offset(2), 'Color', [1 1 1], 'LineStyle', '--', 'LineWidth', 0.25);
      lowHandle = line(uiAx, xData - offset(1), yData - offset(2), 'Color', [1 1 1], 'LineStyle', '--', 'LineWidth', 0.25);
    else
      ctrHandle.XData = xData;
      ctrHandle.YData = yData;
      upHandle.XData = xData + offset(1);
      upHandle.YData = yData + offset(2);
      lowHandle.XData = xData - offset(1);
      lowHandle.YData = yData - offset(2);
    end

    lines.ctrHandle = ctrHandle;
    lines.upHandle = upHandle;
    lines.lowHandle = lowHandle;

  end

end
