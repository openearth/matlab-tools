% instantiate a class
obj = metaprop.example_classdef
obj.Date = now

% interactively inspect it
inspector = obj.inspect
uiwait(inspector.Figure)
obj
datestr(obj.Date)