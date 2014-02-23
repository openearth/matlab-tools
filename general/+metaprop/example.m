% EXAMPLE Example script that shows how to inpect a custom class
%
% See also: metaprop.example_classdef

%% instantiate a class
% an example class
obj = metaprop.example_classdef;

% View the properties of the object
properties(obj)

% Input verification 
try
    obj.Date = '2002/09/01';
catch ME
    disp(ME.message)
end

obj.Date = datenum(2002,9,1);

%% Interactive inspection of class
% open the inspector by calling the objects inspect method
inspector = obj.inspect;
% wait for output
uiwait(inspector.Figure)

fprintf('Date is now set to %s', datestr(obj.Date))