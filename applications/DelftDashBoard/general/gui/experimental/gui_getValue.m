function val=gui_getValue(el,v)
% Gets value from global structure

val=[];

getFcn=getappdata(el.handle,'getFcn');
s=feval(getFcn);

% Variable name
if ~isfield(el,'variableprefix')
    el.variableprefix=[];
end

if ~isempty(el.variableprefix)
    varstring=['s.' el.variableprefix '.' v];
else
    varstring=['s.' v];
end

% assignin(ws, 'var', val);

% Dashboard adaptation
% If variable name starts with 'handles' 
if length(v)>=7
    if strcmpi(v(1:7),'handles')
        varstring=v;
        varstring=strrep(varstring,'handles','s');
    end
end

try
    val=eval(varstring);
catch
    disp(varstring)
end
