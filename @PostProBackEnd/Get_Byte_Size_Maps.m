function [byteSize] = Get_Byte_Size_Maps(PPA)
  % TODO add in-between processing maps 
  % once/if they are ever implemented

  %#ok<*NASGU> 
  byteSize = 0;

  currentMap = PPA.procVolProj; 
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

  currentMap = PPA.procProj;
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

  currentMap = PPA.depthInfo;
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

  currentMap = PPA.maskFrontCMap;
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

  currentMap = PPA.depthImage;
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

  
  currentMap = PPA.FraFilt.raw; 
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

  currentMap = PPA.FraFilt.filt;
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

  currentMap = PPA.FraFilt.filtScales; 
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

  currentMap = PPA.FraFilt.fusedFrangi;
  s = whos('currentMap');
  byteSize = byteSize + s.bytes;

end