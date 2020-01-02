function Update_Frangi_Scales(PPA)

  if PPA.GUI.ManualScalesCheckBox.Value
    scales = str2double(strsplit(PPA.GUI.ScalesTextField.Value));
  else
    startScale = PPA.GUI.StartScaleEditField.Value;
    endScale = PPA.GUI.StopScaleEditField.Value;
    nScales = PPA.GUI.TotalScalesEditField.Value;
    scales = round(linspace(startScale, endScale,nScales)); 
  end
  PPA.scalesToUse = sort(unique(scales)); % make sure we don't double scale ;-)
  nScales = numel(PPA.scalesToUse);

  PPA.GUI.UITable.RowName = 'numbered';
  tdata = table(PPA.scalesToUse', true(nScales, 1));
  PPA.GUI.UITable.Data = tdata;

end
