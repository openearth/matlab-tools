function fig=MakeNewWindow(Name,sz,varargin)

modal=0;

if ~isempty(varargin)
    ii=strmatch('modal',varargin,'exact');
    if ~isempty(ii)
        modal=1;
    end
end

fig=figure;

% d3dpath=[getenv('D3D_HOME') '\' getenv('ARCH') '\'];
% fh = get(fig,'JavaFrame'); % Get Java Frame 
% fh.setFigureIcon(javax.swing.ImageIcon([d3dpath 'delftalmighty\settings\icons\deltares.gif']));

set(fig,'menubar','none');
set(fig,'toolbar','none');
if modal
    set(fig,'windowstyle','modal');
end
set(fig,'Units','pixels');
set(fig,'Position',[0 0 sz(1) sz(2)]);
set(fig,'Name',Name,'NumberTitle','off');
PutInCentre(fig);
