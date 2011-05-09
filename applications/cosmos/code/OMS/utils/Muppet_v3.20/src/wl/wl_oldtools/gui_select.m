function sdim=gui_select(nsel,dimname,enab),
% GUI_SELECT displays a selection window
%            SELECTION=GUI_SELECT(NSELECT,NITEMS,ITEMNAMES)
%            displays a window containing a list of NITEMS items,
%            with names ITEMNAMES. NSELECT items have to be
%            chosen before the window can close.
%            If the items in the list should be referred to as
%            something else than 'items' the following command
%            should be used:
%            SELECTION=GUI_SELECT({NSELECT 'single' 'plural'},
%               NITEMS,ITEMNAMES)
%            If the plural is omitted, then it is constructed by
%            adding an s to the expression specified for 'single'.
%            SELECTION=GUI_SELECT(NSELECT,NITEMS,ITEMNAMES,ENAB)
%            Enables options based on the logical values given by
%            the vector ENAB.
%
%            If ITEMNAMES is omitted, the names are replaced by
%            'item 1', 'item 2', etc. or whatever was specified
%            for the single noun.
%            SIZE(ITEMNAMES,1)=LENGTH(ENAB)=NITEMS

sdim=[];
nocancel=0;

if nargin<2,
  fprintf(1,'* Not enough input arguments.\n');
  return;
elseif nargin>3,
  fprintf(1,'* Too many input arguments.\n');
  return;
end;

LightGray=[1 1 1]*192/255;

if ~iscell(nsel),
  nsel={nsel 'item' 'items'};
elseif (ndims(nsel)==2) & all(size(nsel)==[1 2]),
  nsel={nsel{1} nsel{2} [nsel{2} 's']};
end;

if nsel{1}==1,
  dimens=nsel{2};
else,
  dimens=nsel{3};
end;

if (nargin==2),
  if ischar(dimname), % dimnames in a char matrix
    ndim=size(dimname,1);
    Fig_Width=max(60+7*(size(dimname,2)+4),200);
    enab=ones(ndim,1);
  elseif iscell(dimname), % dimnames in a cell vector
    dimname=str2mat(dimname{:});
    ndim=size(dimname,1);
    Fig_Width=max(60+7*(size(dimname,2)+4),200);
    enab=ones(ndim,1);
  elseif isequal(size(dimname),[1 1]), % number of choice items
    ndim=dimname;
    dimname='';
    Fig_Width=200;
    enab=ones(ndim,1);
  else, % enabled vector
    enab=dimname(:);
    ndim=length(enab);
    dimname='';
    Fig_Width=200;
  end;
elseif (nargin==3),
  ndim=size(dimname,1);
  Fig_Width=max(60+7*(size(dimname,2)+4),200);
end;

if ndim<nsel{1}, % if not enough selectable items: cancel
  sdim=ndim+1;
end;

if isempty(enab), % if no items: cancel
  return;
end;

if sum(enab~=0)<nsel{1}, % if not enough selectable items: cancel
  sdim=ndim+1;
  return;
end;

Field_Height=20;
Margin=20;
Fig_Height=Field_Height*(ndim+2);

ss = get(0,'ScreenSize');
swidth = ss(3);
sheight = ss(4);
left = (swidth-Fig_Width)/2;
bottom = (sheight-Fig_Height)/2;
rect = [left bottom Fig_Width Fig_Height];

fig=figure('menu','none');
set(fig,'units','pixels', ...
        'position',rect, ...
        'color',LightGray, ...
        'inverthardcopy','off', ...
        'closerequestfcn','', ...
        'resize','off', ...
        'numbertitle','off', ...
        'handlevisibility','off', ...
        'name','Select ...', ...
        'tag','Select Window');

for dim=1:ndim,
  if isempty(dimname),
    Str=sprintf('%s %i',nsel{2},dim);
  else,
    Str=sprintf('%s',deblank(dimname(dim,:)));
  end;
  if nsel{1}==1,
    rbstyle='radiobutton';
  else,
    rbstyle='checkbox';
  end;
  rb(dim)=uicontrol('style',rbstyle, ...
            'position',[Margin Fig_Height-(1+dim)*Field_Height Fig_Width-2*Margin Field_Height], ...
            'parent',fig, ...
            'string',Str, ...
            'callback',['set(gcbf,''userdata'',',gui_str(dim),')'], ...
            'enable',logicalswitch(enab(dim),'on','off'));
  gelm_font(rb(dim));
end;

if nsel{1}>1,
  Str=sprintf('Select %i %s ...',nsel{1},dimens);
else,
  Str=sprintf('Select %s ...',dimens);
end;
h=uicontrol('style','text', ...
            'position',[Margin Fig_Height-Field_Height Fig_Width-2*Margin Field_Height], ...
            'string',Str, ...
            'parent',fig);
gelm_font(h);
if nocancel,
  h=uicontrol('style','pushbutton', ...
              'position',[Margin 0 Fig_Width-2*Margin Field_Height], ...
              'string','continue', ...
              'parent',fig, ...
              'callback','set(gcbf,''userdata'',0)');
  gelm_font(h);
else,
  hcanc=uicontrol('style','pushbutton', ...
                  'position',[Margin 0 Fig_Width/2-Margin Field_Height], ...
                  'string','cancel', ...
                  'parent',fig, ...
                  'callback','set(gcbf,''userdata'',-1)');
  gelm_font(hcanc);
  h=uicontrol('style','pushbutton', ...
              'position',[Fig_Width/2 0 Fig_Width/2-Margin Field_Height], ...
              'string','continue', ...
              'parent',fig, ...
              'callback','set(gcbf,''userdata'',0)');
  gelm_font(h);
end;

while length(sdim)~=nsel{1},
  waitfor(fig,'userdata');
  PresRB=get(fig,'userdata');
  if PresRB<0, % cancel
    sdim=ndim+1;
    break;
  end;
  if ~PresRB,
    for dim=1:ndim,
      if get(rb(dim),'value')==1,
        sdim=[sdim dim];
      end;
    end;
    if length(sdim)~=nsel{1},
      Str=sprintf('Please select exactly %i %s.',nsel{1},dimens);
      uiwait(msgbox(Str,'modal'));
      set(fig,'userdata',[]);
      sdim=[];
    end;
  else,
    if nsel{1}==1, % if one toggle between radio buttons
      for dim=1:ndim,
        if get(rb(dim),'value')==1,
          sdim=[sdim dim];
        end;
      end;
      if length(sdim)~=1,
        for dim=1:length(sdim),
          if sdim(dim)~=PresRB,
            set(rb(sdim(dim)),'value',0);
          end;
        end;
      end;
    end;
    sdim=[];
  end;
end;
delete(fig);