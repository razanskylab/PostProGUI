function Gui_Close_Request(obj, ~, ~)
  try
    obj.UserData.Close_Request();
  catch 
    delete(obj);
  end
end
