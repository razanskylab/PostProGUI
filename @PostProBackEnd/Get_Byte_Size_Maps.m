function [byteSize] = Get_Byte_Size_Maps(PPA)
  % TODO add in-between processing maps 
  % once/if they are ever implemented

  %#ok<*NASGU> 
  byteSize = 0;

  currentMap = PPA.procVolProj; % raw untouched vol
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

  currentMap = PPA.procProj; % downsampled volume...
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

  currentMap = PPA.preFrangi; % cropped volume
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

  currentMap = PPA.frangiFilt; % freq. filtered volume
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

  currentMap = PPA.frangiScales; % median filtered volume
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

  currentMap = PPA.frangiCombo;
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

end
