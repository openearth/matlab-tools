function evalinempty(handle,spaceName)

str = getappdata(handle,spaceName);

eval(str);