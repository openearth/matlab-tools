function fig=MakeNewWindow(Name,sz,varargin)

modal=0;

if ~isempty(varargin)
    ii=strmatch('modal',varargin,'exact');
    if ~isempty(ii)
        modal=1;
    end
    for ij=1:length(varargin)
        if exist(varargin{ij},'file') && findstr(varargin{ij},'deltares.gif')
            iconFile=varargin{ij};
        end
    end
end

fig=figure('Visible','off');

fh = get(fig,'JavaFrame'); % Get Java Frame 
if exist('iconFile','var')
    fh.setFigureIcon(javax.swing.ImageIcon(iconFile));
end    

set(fig,'menubar','none');
set(fig,'toolbar','none');
if modal
    set(fig,'windowstyle','modal');
end
set(fig,'Units','pixels');
set(fig,'Position',[0 0 sz(1) sz(2)]);
set(fig,'Name',Name,'NumberTitle','off');
set(fig,'Tag',Name);
PutInCentre(fig);

set(fig,'Visible','on');
