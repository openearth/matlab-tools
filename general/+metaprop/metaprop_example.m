obj = metaprop.metaprop_example
obj.Date = datenum(1670,12,3,10,23,10)
inspector = obj.inspect
uiwait(inspector.Figure)
obj
datestr(obj.Date)