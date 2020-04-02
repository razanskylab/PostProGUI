function [byteSize] = Get_Byte_Size_Volumes(PPA)
  %#ok<*NASGU> 
  byteSize = 0;
  currentVol = PPA.rawVol; % raw untouched vol
  s = whos('currentVol');
  byteSize = byteSize + s.bytes;

  currentVol = PPA.dsVol; % downsampled volume...
  s = whos('currentVol');
  byteSize = byteSize + s.bytes;

  currentVol = PPA.cropVol; % cropped volume
  s = whos('currentVol');
  byteSize = byteSize + s.bytes;

  currentVol = PPA.freqVol; % freq. filtered volume
  s = whos('currentVol');
  byteSize = byteSize + s.bytes;

  currentVol = PPA.filtVol; % median filtered volume
  s = whos('currentVol');
  byteSize = byteSize + s.bytes;

  currentVol = PPA.procVol;
  s = whos('currentVol');
  byteSize = byteSize + s.bytes;

end
