function evalinemptyworkspace(handle,spaceName)

str = getappdata(handle,spaceName);

eval(str);