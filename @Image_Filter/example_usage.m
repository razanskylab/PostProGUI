IM = Image_Filter(map, x, y);
IM = Image_Filter();
% or init with data already
IM.filt = mapRaw;

IM.Plot();
IM.Apply_CLAHE();
