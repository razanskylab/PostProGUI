function postpro_image_click(~, hit, PPA)
  mousePos = hit.IntersectionPoint(1:2);
  PPA.lineCtr = mousePos;
  PPA.Update_Slice_Lines();
end
