function [h,ok]=gui_newWindow(hin,varargin)

% Opens new modal GUI window, based on xml file
% Data is stored in  stored figure's user data

xmlfile=[];
xmldir=[];
elements=[];
hgt=500;
wdt=200;
iconfile=[];
ttl='';
tag='uifigure';
modal=1;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'xmldir'}
                xmldir=varargin{ii+1};
            case{'xmlfile'}
                xmlfile=varargin{ii+1};
            case{'elements'}
                elements=varargin{ii+1};
            case{'height'}
                hgt=varargin{ii+1};
            case{'width'}
                wdt=varargin{ii+1};
            case{'iconfile'}
                iconfile=varargin{ii+1};
            case{'tag'}
                tag=varargin{ii+1};
            case{'title'}
                ttl=varargin{ii+1};
            case{'modal'}
                modal=varargin{ii+1};
        end
    end
end

hin.ok=1;

if ~isempty(xmldir)
    % Load xml file with elements
    xml=gui_readXMLfile(xmlfile,xmldir);
    if isfield(xml,'tag')
        tag=xml.tag;
    else
        tag='uifigure';
    end
    elements=xml.elements;
    sz(1)=str2double(xml.width);
    sz(2)=str2double(xml.height);
    ttl=xml.title;
else
    sz(1)=wdt;
    sz(2)=hgt;
end

if ~isempty(iconfile)
    if modal
        figh=MakeNewWindow(ttl,sz,'modal','iconfile',iconfile);
    else
        figh=MakeNewWindow(ttl,sz,'iconfile',iconfile);
    end
else
    if modal
        figh=MakeNewWindow(ttl,sz,'modal');
    else
        figh=MakeNewWindow(ttl,sz);
    end
end

set(figh,'Tag',tag);

gui_setUserData(hin);

gui_addElements(figh,elements,'getfcn',@gui_getUserData,'setfcn',@gui_setUserData);

set(figh,'CloseRequestFcn',@closefig);

uiwait;

hnew=gui_getUserData;

if hnew.ok
    % Ok, using new user data for output
    h=hnew;
    ok=1;
else
    % Not ok, output is identical to input
    h=hin;
    ok=0;
end

% Remove ok field from output structure
h=rmfield(h,'ok');

% Close the figure
try
    delete(figh);
end

function closefig(hObject,eventdata)
% Same as Cancel
h=gui_getUserData;
h.ok=0;
gui_setUserData(h);
uiresume;
