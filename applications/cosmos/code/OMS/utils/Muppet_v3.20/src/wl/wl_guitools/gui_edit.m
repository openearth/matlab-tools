function [out1,out2,out3,out4,out5,out6] = ...
  gui_edit(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11);
%GUI_EDIT creates an edit window for interactive editing of variables
%      This functions allows you to edit variables in a spreadsheet like way.
%      To edit a variable 'in1', type:
%
%        [out1] = gui_edit(in1);
%
%      The variable 'out1' will contain the edited data. You can edit upto 6
%      matrices of equal dimensions simultaneously by typing them as the first
%      parameters of GUI_EDIT:
%
%        [out1,out2,out3,out4] = gui_edit(in1, in2, in3, in4);
%
%      The elements of the matrices at specific indices can be edited in the
%      upper part of the window. The indices can be selected in the lower part.
%      If one matrix is edited, the editing takes place in the lower part.
%
%      Labels for: the columns  can be specified by the option: 'collabel'
%                  the rows                                     'rowlabel'
%                  the matrices                                 'label'
%
%      Valid values for these options are:
%
%                  'auto'             Auto generated labels, i.e.
%                                      1,2,3, etc. for 'label','rowlabel'
%                                      A,B,C, etc. for 'collabel'
%                                     (default for the editing of non-string
%                                      matrices).
%
%                  'none'             Blank labels (default for the editing
%                                      of string matrices).
%
%                  numeric vector /
%                  string matrix      User defined labels.
%
%      For instance:
%         xt = get(gca,'xtick')';
%         xtl = get(gca,'xticklabels');
%         [xt,xtl] = gui_edit(xt,xtl,'label',str2mat('tick','ticklabel'));
%         set(gca,'xtick',xt,'xticklabels',xtl);
%
%     NOTES:
%      * String matrices are interpreted as a columnvector of strings.
%      * The function does not work properly when used as a part of a
%        buttondownfcn, callback, or similar object generated function.
%      * The number of output variables must match the number of variables
%        to be edited. Editing one matrix
%      * The number of columns is fixed in case of user defined column labels
%        and the editing of string matrices (i.e. one column in that case).
%      * The number of rows is fixed in case of user defined row labels.

%      Copyright (c) Mar 12, 1997 by H.R.A. Jagers
%                                    University of Twente
%                                    The Netherlands

maxwidth=400;
maxheight=300;

if (nargin==0),
  fprintf(1,'* At least one input argument expected.\n');
  return;
elseif (nargout>nargin),
  fprintf(1,'* More output arguments than input argument.\n');
  return;
end;

multiedit=max(nargout,1);

stringedit(multiedit)=0;
sz(multiedit,2)=0;
for i=1:multiedit,
  a = eval(['arg' gui_str(i)]);
  if isstr(a),
    stringedit(i)=1;
  end;
  sz(i,:)=size(a);
end;

all_match=1;
if multiedit>1,
  if any(stringedit),
    if min(min(sz))==0,
      % all should be empty
      all_match=(max(max(sz))==0);
    else,
      % only column vectors are compatible with string vectors
      for i=1:multiedit,
        all_match=all_match & ((sz(i,2)==1) | stringedit(i));
      end;
      all_match=all_match & (min(sz(:,1))==max(sz(:,1)));
      sz=[sz(1,1) 1];
    end;
  else, % only numeric objects
    % both row and column number should be constant
    all_match=all(min(sz)==max(sz));
    sz=sz(1,:);
  end;
end;

if ~all_match,
  fprintf(1,'* These matrices cannot be edited simultaneously.\n');
  return;
end;

ellabelmode=0; % auto
ellabel=' ';
rowlabelmode=0; % auto
rowlabel=' ';
if any(stringedit),
  collabelmode=2; % given
else,
  collabelmode=0; % auto
end;
columnlabel=' ';

if nargin>multiedit,
  if (((nargin-multiedit)/2)-fix((nargin-multiedit)/2)>.25),
    fprintf(1,'* Invalid number of option arguments.\n');
    return;
  end;
  for i=(multiedit+1):2:nargin,
    arg = eval(['arg' gui_str(i)]);
    if ~isstr(arg),
      fprintf(1,'* Option %i is not correct.\n',i-multiedit);
      return;
    end;
    if strcmp(arg,'label'),
      if multiedit==1,
        fprintf(1,'* Option ''label'' not available if one item is edited.\n');
        return;
      end;
      ellabel = eval(['arg' gui_str(i+1)]);
      ellabelmode = 2; % given
      if isstr(ellabel),
        if all(size(ellabel)==[1 4]),
          if all(ellabel=='auto'),
            if any(stringedit),
              ellabelmode=1; % none
            else,
              ellabelmode=0; % auto
            end;
          elseif all(ellabel=='none'),
            ellabelmode=1; % none
          end;
        end;
      end;
      if ellabelmode==2, %given
        if ~isstr(ellabel),
          if min(size(ellabel))~=1,
            fprintf(1,'* Array of labels expected.\n');
            return;
          end;
          % make column vector
          if size(ellabel,1)==1,
            ellabel=ellabel';
          end;
          % make string
          labels=gui_str(ellabel(1));
          for i=2:size(ellabel,1),
            labels=str2mat(labels,gui_str(ellabel(i)));
          end;
          ellabel=labels;
        end;
        if size(ellabel,1)~=multiedit,
          fprintf(1,'* Number of labels does not match the number of editable matrices.\n');
          return;
        end;
      else,
        ellabel=' ';
      end;
    elseif strcmp(arg,'collabel'),
      columnlabel = eval(['arg' gui_str(i+1)]);
      collabelmode = 2; %given
      if ~any(stringedit),
        if isstr(columnlabel),
          if all(size(columnlabel)==[1 4]),
            if all(columnlabel=='auto'),
              collabelmode=0; % auto
            elseif all(columnlabel=='none'),
              collabelmode=1; % none
            end;
          end;
        end;
      end;
      if collabelmode==2, %given
        if ~isstr(columnlabel),
          if min(size(columnlabel))~=1,
            fprintf(1,'* Array of column labels expected.\n');
            return;
          end;
          % make column vector
          if size(columnlabel,1)==1,
            columnlabel=columnlabel';
          end;
          % make string
          labels=gui_str(columnlabel(1));
          for i=2:size(columnlabel,1),
            labels=str2mat(labels,gui_str(columnlabel(i)));
          end;
          columnlabel=labels;
        end;
        if size(columnlabel,1)~=sz(2),
          fprintf(1,'* Number of column labels does not match the number of columns.\n');
          return;
        end;
      else,
        columnlabel=' ';
      end;
    elseif strcmp(arg,'rowlabel'),
      rowlabel = eval(['arg' gui_str(i+1)]);
      rowlabelmode = 2; %given
      if isstr(rowlabel),
        if all(size(rowlabel)==[1 4]),
          if all(rowlabel=='auto'),
            rowlabelmode=0; % auto
          elseif all(rowlabel=='none'),
            rowlabelmode=1; % none
          end;
        end;
      end;
      if rowlabelmode==2, %given
        if ~isstr(rowlabel),
          if min(size(rowlabel))~=1,
            fprintf(1,'* Array of row labels expected.\n');
            return;
          end;
          % make column vector
          if size(rowlabel,1)==1,
            rowlabel=rowlabel';
          end;
          % make string
          labels=gui_str(rowlabel(1));
          for i=2:size(rowlabel,1),
            labels=str2mat(labels,gui_str(rowlabel(i)));
          end;
          rowlabel=labels;
        end;
        if size(rowlabel,1)~=sz(1),
          fprintf(1,'* Number of row labels does not match the number of rows.\n');
          return;
        end;
      else,
        rowlabel=' ';
      end;
    else,
      fprintf(1,'* Invalid option ''%s''.\n', arg);
    end;
  end;
end;

width = 55;
height = 20;

charwidth = 7; % actually 6.8886 +/- 0.4887

% if row labels are given then the number of rows is fixed, else show maximum
if rowlabelmode==2,
  show_numberrows = size(rowlabel,1);
  % rowlabelwidth depends on length of the row labels with the constraints that
  % they occupy at most half of the maximum edit window width and at least the
  % default width specified above.
  if (1.2*size(rowlabel,2)*charwidth+10)>(maxwidth/2),
    rowlabel=rowlabel(:,1:fix((maxwidth-20)/(2.4*charwidth)));
  end;
  if (1.2*size(ellabel,2)*charwidth+10)>(maxwidth/2),
    ellabel=ellabel(:,1:fix((maxwidth-20)/(2.4*charwidth)));
  end;
  rwidth=max(size(rowlabel,2),size(ellabel,2));
  rowlabelwidth = round(max(width,1.2*rwidth*charwidth+10));
else,
  show_numberrows = 100;
  rowlabelwidth = width;
end;

% if column labels are given then the number of columns is fixed, else show maximum
if collabelmode==2,
  show_numbercolumns = size(columnlabel,1);
else,
  show_numbercolumns = 100;
end;

if multiedit==1,
  % columnlabelwidth depends on length of the column labels with the constraints
  % that they occupy at most the remaining width of the edit window (i.e. after
  % defining the rowlabelwidth) and at least the default width specified above.
  cwidth=max(size(columnlabel,2));
  if stringedit, % stringedit is scalar for multiedit==1,
    cwidth=max(cwidth,sz(2));
  else,
    for i=1:sz(1)
      cwidth=max(cwidth,size(gui_str(a(i,:),'vec'),2));
    end;
  end;
  if (1.2*cwidth*charwidth+10)>(maxwidth-rowlabelwidth),
    cwidth=fix((maxwidth-rowlabelwidth-10)/(1.2*charwidth));
    if size(columnlabel,2)>cwidth,
      columnlabel=columnlabel(:,1:cwidth);
    end;
  end;
  columnlabelwidth = round(max(width,1.2*cwidth*charwidth+10));
else,
  columnlabelwidth = width;
end;

totalwidth = rowlabelwidth+show_numbercolumns*columnlabelwidth;
mwwidth = max(totalwidth,94); % for PCWIN minimum width is 94
mwheight = (show_numberrows+2)*height;
if multiedit>1,
  mwheight = mwheight+multiedit*height;
end;

horizontalscrollbar=0;
verticalscrollbar=0;
if any(stringedit),
  mwwidth = maxwidth - 20;
  columnlabelwidth = mwwidth - rowlabelwidth;
else, 
  if mwwidth>maxwidth,
    % add space for scrollbar
    mwheight=mwheight+20;
    horizontalscrollbar=1;
    % reduce the number of columns to fit the maxwidth
    decrease=ceil((mwwidth-maxwidth)/columnlabelwidth);
    show_numbercolumns=show_numbercolumns-decrease;
    % set new width
    mwwidth = mwwidth-decrease*columnlabelwidth;
  end;
end;

if mwheight>maxheight,
  % add space for scrollbar
  mwwidth=mwwidth+20;
  verticalscrollbar=1;
  % reduce the number of rows to fit the maxheight
  decrease=ceil((mwheight-maxheight)/height);
  show_numberrows=show_numberrows-decrease;
  % set new height
  mwheight = mwheight-decrease*height;
end;

if multiedit>1,
  verticaloffset=multiedit;
else,
  verticaloffset=0;
end;

for i=1:multiedit,
  eval(['out' gui_str(i) ' = arg' gui_str(i) ';']);
end;

i1=min(show_numberrows,size(a,1));
j1=min(show_numbercolumns,size(a,2));

ss = get(0,'ScreenSize');
swidth = ss(3);
sheight = ss(4);
PointerLoc=get(0,'PointerLocation');
left = (swidth-mwwidth)/2;
bottom = (sheight-mwheight)/2;
rect = [left bottom mwwidth mwheight];

fig=figure('menu','none','visible','off');
%set up window if necessary
bgc=[0.7529 0.7529 0.7529];
col_edit=[1 1 1];
col_select=[0.651 0.7922 0.9412];
set(fig,'units','pixels', ...
        'position',rect, ...
        'color',bgc, ...
        'inverthardcopy','off', ...
        'resize','off', ...
        'numbertitle','off', ...
        'name','Edit window');
ax1=gca;
set(ax1,'units','normalized', ...
    'position',[0 0 1 1], ...
    'xlim',[1 mwwidth],'ylim',[1 mwheight], ...
    'visible','off')

if multiedit==1,
  x=uicontrol('units','pixels', ...
    'position',[0 mwheight-(2+verticaloffset)*height rowlabelwidth 2*height], ...
    'userdata',[]);
else,
  x=uicontrol('units','pixels', ...
    'position',[0 mwheight-(2+verticaloffset)*height rowlabelwidth 2*height], ...
    'string','-', ...
    'userdata',[]);
end;
Hx=['hex2num(''',num2hex(x),''')'];
set(x,'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[-1 5]))']);

mainbuttonwidth=(mwwidth-rowlabelwidth)/2;
rset=uicontrol('units','pixels', ...
  'position',[rowlabelwidth mwheight-(1+verticaloffset)*height mainbuttonwidth height], ...
  'string','reset', ...
  'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[-1 4]))']);
accept=uicontrol('units','pixels', ...
  'position',[rowlabelwidth+mainbuttonwidth mwheight-(1+verticaloffset)*height mainbuttonwidth height], ...
  'string','accept', ...
  'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[-1 1]))']);

columnbutton(show_numbercolumns)=0;
for j=1:show_numbercolumns,
  if collabelmode==2,
    str=columnlabel(j,:);
  elseif collabelmode==1,
    str='';
  else, % collabelmode==0
    str=collabel(j);
  end;
  if collabelmode==2,
    columnbutton(j)=uicontrol('units','pixels', ...
      'position',[rowlabelwidth+(j-1)*columnlabelwidth mwheight-(2+verticaloffset)*height columnlabelwidth height], ...
      'string',str);
  else,
    columnbutton(j)=uicontrol('units','pixels', ...
      'position',[rowlabelwidth+(j-1)*columnlabelwidth mwheight-(2+verticaloffset)*height columnlabelwidth height], ...
      'string',str, ...
      'buttondownfcn',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[0 ',gui_str(j),']))'], ...
      'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[0 ',gui_str(j),']))']);
  end;
end;
set(columnbutton((j1+1):show_numbercolumns),'visible','off');

elementbutton=[];
elementvalue=[];
if verticaloffset,
  for i=1:verticaloffset,
    if ellabelmode==2,
      str=ellabel(i,:);
    elseif ellabelmode==1,
      str='';
    else, % rowlabelmode==0
      str=gui_str(i);
    end;
    elementbutton(i)=uicontrol('units','pixels', ...
      'position',[0 mwheight-i*height rowlabelwidth height], ...
      'string',str);
    elementvalue(i)=uicontrol('units','pixels', ...
      'position',[rowlabelwidth mwheight-i*height mwwidth-rowlabelwidth height], ...
      'style','edit', ...
      'enable','off', ...
      'backgroundcolor',col_edit, ...
      'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[-4 ',gui_str(i),']))']);
  end;
end;

rowbutton(show_numberrows)=0;
for i=1:show_numberrows,
  if rowlabelmode==2,
    str=rowlabel(i,:);
  elseif rowlabelmode==1,
    str='';
  else, % rowlabelmode==0
    str=gui_str(i);
  end;
  if rowlabelmode==2,
    rowbutton(i)=uicontrol('units','pixels', ...
      'position',[0 mwheight-(i+2+verticaloffset)*height rowlabelwidth height], ...
      'string',str);
  else,
    rowbutton(i)=uicontrol('units','pixels', ...
      'position',[0 mwheight-(i+2+verticaloffset)*height rowlabelwidth height], ...
      'string',str, ...
      'buttondownfcn',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[',gui_str(i),' 0]))'], ...
      'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[',gui_str(i),' 0]))']);
  end;
end;
set(rowbutton((i1+1):show_numberrows),'visible','off');

vsb=[];
i0=0; % i0 is upper row number minus one; so rows i0+1 to i0+show_numberrows are shown (if available)
i0max=size(a,1)-i1;
if verticalscrollbar,
  uicontrol('units','pixels', ...
    'position',[rowlabelwidth+show_numbercolumns*columnlabelwidth mwheight-(2+verticaloffset)*height 20 height], ...
    'enable','off');
  vsb=uicontrol('units','pixels', ...
   'position',[rowlabelwidth+show_numbercolumns*columnlabelwidth 20*horizontalscrollbar 20 height*show_numberrows], ...
   'style','slider', ...
   'min',-i0max,'max',0,'visible',set2on(i0max~=0));
  set(vsb,'value',0, ...
   'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[-1 3]))']);
end;

hsb=[];
j0=0; % j0 left column number minus one, so columns j0+1 to j0+show_numbercolumns are shown (if available)
j0max=size(a,2)-j1;
if horizontalscrollbar,
  uicontrol('units','pixels', ...
    'position',[0 0 rowlabelwidth height], ...
    'enable','off');
  uicontrol('units','pixels', ...
    'position',[rowlabelwidth+show_numbercolumns*columnlabelwidth 0 20 height], ...
    'enable','off');
  hsb=uicontrol('units','pixels', ...
   'position',[rowlabelwidth 0 show_numbercolumns*columnlabelwidth height], ...
   'style','slider', ...
   'min',0,'max',j0max,'visible',set2on(j0max~=0));
  set(hsb,'value',0, ...
   'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[-1 2]))']);
end;

cell(show_numberrows,show_numbercolumns)=0;
if multiedit>1,
  for i=1:show_numberrows,
    for j=1:show_numbercolumns,
      cell(i,j)=uicontrol('units','pixels', ...
        'position',[rowlabelwidth+(j-1)*columnlabelwidth mwheight-(i+2+verticaloffset)*height columnlabelwidth height], ...
        'style','text', ...
        'backgroundcolor',col_edit, ...
        'buttondownfcn',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[',gui_str(i),' ',gui_str(j),']))']);
    end;
  end;
else,
  for i=1:show_numberrows,
    for j=1:show_numbercolumns,
      cell(i,j)=uicontrol('units','pixels', ...
        'position',[rowlabelwidth+(j-1)*columnlabelwidth mwheight-(i+2+verticaloffset)*height columnlabelwidth height], ...
        'style','edit', ...
        'backgroundcolor',col_edit, ...
        'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[',gui_str(i),' ',gui_str(j),']))']);
    end;
  end;
end;
if multiedit==1,
  for i=1:i1,
    if stringedit,
      set(cell(i,1),'string',out1(i,:));
    else,
      for j=1:j1,
        set(cell(i,j),'string',gui_str(out1(i,j)));
      end;
    end;
  end;
else,
  for i=1:i1,
    for j=1:j1,
      set(cell(i,j),'string',[ collabel(j) gui_str(i)]);
    end;
  end;
end;
set(cell((i1+1):show_numberrows,:),'visible','off');
set(cell(1:i1,(j1+1):show_numbercolumns),'visible','off');

hinsert=uimenu('label','&Insert');
hrowmenu=uimenu(hinsert,'label','&Row');
ins_ra=uimenu(hrowmenu, ...
   'label','&Above selected', ...
   'enable','off', ...
   'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[-2 1]))']);
ins_rb=uimenu(hrowmenu, ...
   'label','&Below selected', ...
   'enable','off', ...
   'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[-2 2]))']);
hcolmenu=uimenu(hinsert, ...
   'separator','on', ...
   'label','&Column');
ins_cl=uimenu(hcolmenu, ...
   'label','&Left of selected', ...
   'enable','off', ...
   'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[-2 3]))']);
ins_cr=uimenu(hcolmenu, ...
   'label','&Right of selected', ...
   'enable','off', ...
   'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[-2 4]))']);

hdelete=uimenu('label','&Delete');
del_r=uimenu(hdelete, ...
   'label','Selected &row', ...
   'enable','off', ...
   'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[-3 1]))']);
del_c=uimenu(hdelete, ...
   'label','Selected &column', ...
   'enable','off', ...
   'callback',['set(',Hx,',''userdata'',cmdstack(get(',Hx,',''userdata''),[-3 2]))']);

set(fig,'pointer','arrow');
set(fig,'visible','on');
%waitforbuttonpress;
qqq=findobj;
for i=1:size(qqq), set(qqq(i),'interruptible','on'); end;
drawnow;

selectedcolumn=[];
selectedrow=[];
gui_quit=0;
stack=[];
i2=[]; % indices of cell displayed in upper half
j2=[];

while ~gui_quit,
  drawnow
  prevstack=stack;
  if ishandle(x),
    stack=get(x,'userdata');
%    if stack~=prevstack; stack, end;
    set(x,'userdata',[]);
  else,
    gui_quit=1;
  end;
  while ~isempty(stack),
    cmd=stack(1,:);
    stack=stack(2:size(stack,1),:);
    if min(cmd)>0, % cell edited (or clicked in case of multiedit)
      set(fig,'pointer','watch');
      if multiedit>1,
        i2=i0+cmd(1);
        j2=j0+cmd(2);
        for i=1:multiedit,
          set(elementvalue(i),'visible','off');
          if stringedit(i),
            set(elementvalue(i),'string',gui_str(eval(['out' gui_str(i) '(' gui_str(i2) ',:)'])));
          else
            set(elementvalue(i),'string',gui_str(eval(['out' gui_str(i) '(' gui_str(i2) ',' gui_str(j2) ')'])));
          end;
          set(elementvalue(i),'visible','on','enable','on');
        end;
        set(x,'string',[collabel(j2) gui_str(i2)]);
      else,
        set(cell(cmd(1),cmd(2)),'visible','off');
        if stringedit,
          str=get(cell(cmd(1),cmd(2)),'string');
          if length(str)>size(out1,2),
            out1=[out1 32*ones(size(out1,1),length(str)-size(out1,2))];
            out1(i0+cmd(1),:)=str;
          else,
            out1(i0+cmd(1),:)=[str 32*ones(1,size(out1,2)-length(str))];
          end;
          set(cell(cmd(1),cmd(2)),'string',gui_str(out1(cmd(1),:)));
        else, % evaluate entry
          temp=eval(get(cell(cmd(1),cmd(2)),'string'),'NaN');
          if isnan(temp), % check if it is an error or in fact really NaN
            temp=eval(get(cell(cmd(1),cmd(2)),'string'),'0');
            if temp==0,
              echo on
              fprintf(1,'* error during evaluation of input\n');
              echo off
            else,
              out1(i0+cmd(1),j0+cmd(2))=NaN;
            end;
          else,
            if (size(temp)==[1 1]),
              out1(i0+cmd(1),j0+cmd(2))=temp;
            else,
              echo on
              fprintf(1,'* input must evaluate to scalar\n');
              echo off
            end;
          end;
          set(cell(cmd(1),cmd(2)),'string',gui_str(out1(i0+cmd(1),j0+cmd(2))));
        end;
        set(cell(cmd(1),cmd(2)),'visible','on');
      end;
      set(fig,'pointer','arrow');
    elseif min(cmd)==0, % row or column selection
      set(fig,'pointer','watch');
      if cmd(1)==0, % column toggle
        if ~isempty(selectedrow),
          rows=[1:(selectedrow-1),(selectedrow+1):show_numberrows];
        else,
          rows=1:show_numberrows;
        end;
        if ~isempty(selectedcolumn),
          set(columnbutton(selectedcolumn),'style','pushbutton');
          set(cell(rows,selectedcolumn),'backgroundcolor',col_edit);
        end;
        if isempty(selectedcolumn) | (cmd(2)~=selectedcolumn),
          selectedcolumn=cmd(2);
        else,
          selectedcolumn=[];
        end;
        if ~isempty(selectedcolumn),
          set(columnbutton(selectedcolumn),'style','text');
          set(cell(rows,selectedcolumn),'backgroundcolor',col_select);
          set([ins_cl ins_cr del_c],'enable','on');
        else,
          set([ins_cl ins_cr del_c],'enable','off');
        end;
      else, % cmd(2)==0, % row toggle
        if ~isempty(selectedcolumn),
          columns=[1:(selectedcolumn-1),(selectedcolumn+1):show_numbercolumns];
        else,
          columns=1:show_numbercolumns;
        end;
        if ~isempty(selectedrow),
          set(rowbutton(selectedrow),'style','pushbutton');
          set(cell(selectedrow,columns),'backgroundcolor',col_edit);
        end;
        if isempty(selectedrow) | (cmd(1)~=selectedrow),
          selectedrow=cmd(1);
        else,
          selectedrow=[];
        end;
        if ~isempty(selectedrow),
          set(rowbutton(selectedrow),'style','text');
          set(cell(selectedrow,columns),'backgroundcolor',col_select);
          set([ins_ra ins_rb del_r],'enable','on');
        else,
          set([ins_ra ins_rb del_r],'enable','off');
        end;
      end;
      set(fig,'pointer','arrow');
    elseif cmd(1)==-1, % other button
      set(fig,'pointer','watch');
      if cmd(2)==1, % exit code
        gui_quit=1;
      elseif cmd(2)==2, % horizontal scrollbar
        j0prev=j0;
        j0=get(hsb,'value');
        if (j0>j0prev),
          j0=max(round(j0),min(j0prev+1,size(out1,2)-j1));
        elseif(j0<j0prev),
          j0=min(round(j0),max(j0prev-1,0));
        end;
        if (j0~=j0prev),
          if ~isempty(selectedcolumn),
            % select moved column
            newcolumn=selectedcolumn-j0+j0prev;
            % if selected column moves out of sight,
            % unselect selected column
            if newcolumn>show_numbercolumns,
              newcolumn=selectedcolumn;
            elseif newcolumn<1,
              newcolumn=selectedcolumn;
            end;
            stack=cmdstack(stack,[0 newcolumn]);
          end;
          set(hsb,'value',j0);
          set(cell,'visible','off');
          if collabelmode==2, % given
            for j=1:show_numbercolumns,
              set(columnbutton(j),'string',columnlabel(j+j0,:));
            end;
          elseif collabelmode==0, % auto
            for j=1:show_numbercolumns,
              set(columnbutton(j),'string',collabel(j+j0));
            end;
          end;
          if multiedit==1,
            for i=1:i1,
              for j=1:j1,
                set(cell(i,j),'string',gui_str(out1(i+i0,j+j0)));
              end;
            end;
          else,
            for i=1:i1,
              for j=1:j1,
                set(cell(i,j),'string',[collabel(j+j0) gui_str(i+i0)]);
              end;
            end;
          end;
          set(cell(1:i1,1:j1),'visible','on');
        end;
      elseif cmd(2)==3, % vertical scrollbar
        i0prev=i0;
        i0=-get(vsb,'value');
        if (i0>i0prev),
          i0=max(round(i0),min(i0prev+1,size(out1,1)-i1));
        elseif(i0<i0prev),
          i0=min(round(i0),max(i0prev-1,0));
        end;
        if (i0~=i0prev),
          if ~isempty(selectedrow),
            % select moved row
            newrow=selectedrow-i0+i0prev;
            % if selected row moves out of sight,
            % unselect selected row
            if newrow>show_numberrows,
              newrow=selectedrow;
            elseif newrow<1,
              newrow=selectedrow;
            end;
            stack=cmdstack(stack,[newrow 0]);
          end;
          set(vsb,'value',-i0);
          set(cell,'visible','off');
          if rowlabelmode==2, % given
            for i=1:show_numberrows,
              set(rowbutton(i),'string',rowlabel(i+i0,:));
            end;
          elseif rowlabelmode==0, % auto
            for i=1:show_numberrows,
              set(rowbutton(i),'string',gui_str(i+i0));
            end;
          end;
          if multiedit==1,
            for i=1:i1,
              if stringedit,
                set(cell(i,1),'string',out1(i+i0,:));
              else,
                for j=1:j1,
                  set(cell(i,j),'string',gui_str(out1(i+i0,j+j0)));
                end;
              end;
            end;
          else,
            for i=1:i1,
              for j=1:j1,
                set(cell(i,j),'string',[collabel(j+j0) gui_str(i+i0)]);
              end;
            end;
          end;
          set(cell(1:i1,1:j1),'visible','on');
        end;
      elseif cmd(2)==4, % reset
        if (~isempty(selectedrow)) | (~isempty(selectedcolumn)),
          stack=cmdstack(stack,[-1 4],'top');
          if ~isempty(selectedcolumn),
            stack=cmdstack(stack,[0 selectedcolumn],'top');
          end;
          if ~isempty(selectedrow),
            stack=cmdstack(stack,[selectedrow 0],'top');
          end;
        end;
        for i=1:multiedit,
          eval(['out' gui_str(i) ' = arg' gui_str(i) ';']);
        end;
        i0=0;
        j0=0;
        i1=min(show_numberrows,size(arg1,1));
        if ~any(stringedit),
          j1=min(show_numbercolumns,size(arg1,2));
        else,
          j1=min(1,size(arg1,2));
        end;
        set(cell,'visible','off');
        if multiedit==1,
          %reset all visible elements
          for i=1:i1,
            if stringedit,
              set(cell(i,1),'string',arg1(i+i0,:));
            else,
              for j=1:j1,
                set(cell(i,j),'string',gui_str(arg1(i+i0,j+j0)));
              end;
            end;
          end;
        else,
          %reset all visible cells
          for i=1:i1,
            for j=1:j1,
              set(cell(i,j),'string',[collabel(j+j0) gui_str(i+i0)]);
            end;
          end;
          %reset elements in upper plane
          for i=1:multiedit,
            set(elementvalue(i),'string','','enable','off');
          end;
          set(x,'string','-');
        end;
        %reset all rowlabels
        if rowlabelmode==2, % given
          for i=1:i1,
            set(rowbutton(i),'string',rowlabel(i));
          end;
        elseif rowlabelmode==0, % auto
          for i=1:i1,
            set(rowbutton(i),'string',gui_str(i));
          end;
        end;
        %reset all columnlabels
        if collabelmode==2, % given
          for j=1:j1,
            set(columnbutton(j),'string',columnlabel(j));
          end;
        elseif collabelmode==0, % auto
          for j=1:j1,
            set(columnbutton(j),'string',collabel(j));
          end;
        end;
        set(vsb,'visible',set2on(get(vsb,'max')~=-max(size(out1,1)-show_numberrows,0)));
        set(vsb,'min',-max(size(out1,1)-show_numberrows,0),'value',0);
        set(hsb,'visible',set2on(get(vsb,'min')~=-max(size(out1,2)-show_numbercolumns,0)));
        set(hsb,'max',max(size(out1,2)-show_numbercolumns,0),'value',0);
        set(rowbutton(1:i1),'visible','on');
        set(columnbutton(1:j1),'visible','on');
        set(cell(1:i1,1:j1),'visible','on');
        set(rowbutton((i1+1):show_numberrows),'visible','off');
        set(columnbutton((j1+1):show_numbercolumns),'visible','off');
        set(cell((i1+1):show_numberrows,:),'visible','off');
        set(cell(1:i1,(j1+1):show_numbercolumns),'visible','off');
      elseif cmd(2)==5, % clear upper plane or create one cell
        if multiedit==1, % if empty create one cell of correct type
          if isempty(out1),
            if stringedit,
              out1=' ';
            else,
              out1=0;
            end;
            set(cell(1,1),'visible','on','string',gui_str(out1));
            set(columnbutton(1),'visible','on');
            set(rowbutton(1),'visible','on');
          end;
        else, % multiedit > 1
          if isempty(out1),
            %create one cell
            for i=1:multiedit,
              if stringedit(i),
                eval(['out' gui_str(i) ' = '' '';']);
              else,
                eval(['out' gui_str(i) ' = 0;']);
              end;
            end;
            set(cell(1,1),'visible','on','string','A1');
            set(columnbutton(1),'visible','on');
            set(rowbutton(1),'visible','on');
          else,
            %reset elements in upper plane
            for i=1:multiedit,
              set(elementvalue(i),'string','','enable','off');
            end;
            set(x,'string','-');
          end;
        end;
      end;
      set(fig,'pointer','arrow');
    elseif cmd(1)==-2, % insert menu
      set(fig,'pointer','watch');
      if cmd(2)==1, % insert row above selected
        for i=1:multiedit,
          a=gui_str(i);
          if stringedit(i),
            eval(['out' a ' = [out' a '(1:i0+selectedrow-1,:);' ...
                              '32*ones(1,size(out' a ',2));' ...
                              'out' a '(i0+selectedrow:size(out' a ',1),:)];']);
          else,
            eval(['out' a ' = [out' a '(1:i0+selectedrow-1,:);' ...
                              'zeros(1,size(out' a ',2));' ...
                              'out' a '(i0+selectedrow:size(out' a ',1),:)];']);
          end;
        end;
        if (i1==show_numberrows),
          i0=i0+1;
        else,
          stack=cmdstack(stack,[selectedrow+1 0]);
        end;
        if (~isempty(i2)) & (i2>=selectedrow),
          i2=i2+1;
        end;
      elseif cmd(2)==2, % insert row below selected
        for i=1:multiedit,
          a=gui_str(i);
          if stringedit(i),
            eval(['out' a ' = [out' a '(1:i0+selectedrow,:);' ...
                              '32*ones(1,size(out' a ',2));' ...
                              'out' a '(i0+selectedrow+1:size(out' a ',1),:)];']);
          else,
            eval(['out' a ' = [out' a '(1:i0+selectedrow,:);' ...
                              'zeros(1,size(out' a ',2));' ...
                              'out' a '(i0+selectedrow+1:size(out' a ',1),:)];']);
          end;
        end;
        if (~isempty(i2)) & (i2>selectedrow),
          i2=i2+1;
        end;
      elseif cmd(2)==3, % insert column left of selected
        for i=1:multiedit,
          a=gui_str(i);
          eval(['out' a ' = [out' a '(:,1:(j0+selectedcolumn-1)),' ...
                            'zeros(size(out' a ',1),1),' ...
                            'out' a '(:,(j0+selectedcolumn):size(out' a ',2))];']);
        end;
        if (j1==show_numbercolumns),
          j0=j0+1;
        else,
          stack=cmdstack(stack,[0 selectedcolumn+1]);
        end;
        if (~isempty(j2)) & (j2>=selectedcolumn),
          j2=j2+1;
        end;
      elseif cmd(2)==4, % insert column right of selected
        for i=1:multiedit,
          a=gui_str(i);
          eval(['out' a ' = [out' a '(:,1:j0+selectedcolumn),' ...
                            'zeros(size(out' a ',1),1),' ...
                            'out' a '(:,j0+selectedcolumn+1:size(out' a ',2))];']);
        end;
        if (~isempty(j2)) & (j2>selectedcolumn),
          j2=j2+1;
        end;
      end;
      set(vsb,'visible',set2on(get(vsb,'max')~=-max(size(out1,1)-show_numberrows,0)));
      set(vsb,'min',-max(size(out1,1)-show_numberrows,0),'value',-i0);
      set(hsb,'visible',set2on(get(vsb,'min')~=-max(size(out1,2)-show_numbercolumns,0)));
      set(hsb,'max',max(size(out1,2)-show_numbercolumns,0),'value',j0);
      i1=min(show_numberrows,size(out1,1));
      j1=min(show_numbercolumns,size(out1,2));
      if multiedit==1,
        for i=1:i1,
          if stringedit,
            set(cell(i,1),'string',out1(i+i0,:));
          else,
            for j=1:j1,
              set(cell(i,j),'string',gui_str(out1(i+i0,j+j0)));
            end;
          end;
        end;
      else,
        for i=1:i1,
          for j=1:j1,
            set(cell(i,j),'string',[collabel(j+j0) gui_str(i+i0)]);
          end;
        end;
        set(x,'string',[collabel(j2) gui_str(i2)]);
      end;
      %set all rowlabels
      if rowlabelmode==2, % given
        for i=1:i1,
          set(rowbutton(i),'string',rowlabel(i+i0));
        end;
      elseif rowlabelmode==0, % auto
        for i=1:i1,
          set(rowbutton(i),'string',gui_str(i+i0));
        end;
      end;
      %set all columnlabels
      if collabelmode==2, % given
        for j=1:j1,
          set(columnbutton(j),'string',columnlabel(j+j0));
        end;
      elseif collabelmode==0, % auto
        for j=1:j1,
          set(columnbutton(j),'string',collabel(j+j0));
        end;
      end;
      set(rowbutton(1:i1),'visible','on');
      set(columnbutton(1:j1),'visible','on');
      set(cell(1:i1,1:j1),'visible','on');
      set(fig,'pointer','arrow');
    elseif cmd(1)==-3, % delete menu
      set(fig,'pointer','watch');
      if cmd(2)==1, % delete row
        for i=1:multiedit,
          a=gui_str(i);
          eval(['out' a ' = [out' a '(1:(i0+selectedrow-1),:);' ...
                            'out' a '((i0+selectedrow+1):size(out' a ',1),:)];']);
        end;
        stack=cmdstack(stack,[selectedrow 0]);
        if ~isempty(i2),
          if i2>selectedrow,
            i2=i2-1;
          elseif i2==selectedrow,
            i2=[];
          end;
        end;
      elseif cmd(2)==2, % delete column
        for i=1:multiedit,
          a=gui_str(i);
          eval(['out' a ' = [out' a '(:,1:(j0+selectedcolumn-1)),' ...
                            'out' a '(:,(j0+selectedcolumn+1):size(out' a ',2))];']);
        end;
        stack=cmdstack(stack,[0 selectedcolumn]);
        if ~isempty(j2),
          if j2>selectedcolumn,
            j2=j2-1;
          elseif j2==selectedcolumn,
            j2=[];
          end;
        end;
      end;
      set(cell,'visible','off');
      if (i0+show_numberrows)>size(out1,1),
        i0=size(out1,1)-show_numberrows;
        if i0<0,
          i0=0;
          set(rowbutton((size(out1,1)+1):show_numberrows),'visible','off');
          set(cell((size(out1,1)+1):show_numberrows,:),'visible','off');
        end;
      end;
      if (j0+show_numbercolumns)>size(out1,2),
        j0=size(out1,2)-show_numbercolumns;
        if j0<0,
          j0=0;
          set(columnbutton((size(out1,2)+1):show_numbercolumns),'visible','off');
          set(cell(:,(size(out1,2)+1):show_numbercolumns),'visible','off');
        end;
      end;
      set(vsb,'visible',set2on(get(vsb,'max')~=-max(size(out1,1)-show_numberrows,0)));
      set(vsb,'min',-max(size(out1,1)-show_numberrows,0));
      set(hsb,'visible',set2on(get(vsb,'min')~=-max(size(out1,2)-show_numbercolumns,0)));
      set(hsb,'max',max(size(out1,2)-show_numbercolumns,0));
      i1=min(show_numberrows,size(out1,1));
      j1=min(show_numbercolumns,size(out1,2));
      if multiedit==1,
        for i=1:i1,
          if stringedit,
            set(cell(i,1),'string',out1(i+i0,:));
          else,
            for j=1:j1,
              set(cell(i,j),'string',gui_str(out1(i+i0,j+j0)));
            end;
          end;
        end;
      else,
        for i=1:i1,
          for j=1:j1,
            set(cell(i,j),'string',[collabel(j+j0) gui_str(i+i0)]);
          end;
        end;
        if isempty(i2) | isempty(j2),
          %reset elements in upper plane
          for i=1:multiedit,
            set(elementvalue(i),'string','','enable','off');
          end;
          set(x,'string','-');
        else,
          set(x,'string',[collabel(j2) gui_str(i2)]);
        end;
      end;
      set(cell(1:i1,1:j1),'visible','on');
      set(fig,'pointer','arrow');
    elseif cmd(1)==-4, % elements of multiedit
      set(fig,'pointer','watch');
      i=cmd(2);
      set(elementvalue(i),'visible','off');
      a=eval(['out' gui_str(i)]);
      str=get(elementvalue(i),'string');
      if stringedit(i),
        if length(str)>size(a,2),
          a=[a 32*ones(size(a,1),length(str)-size(a,2))];
          a(i0+i2,:)=str;
        else,
          a(i0+i2,:)=[str 32*ones(1,size(a,2)-length(str))];
        end;
        set(elementvalue(i),'string',gui_str(a(i2,:)));
      else, % evaluate entry
        temp=eval(str,'NaN');
        if isnan(temp), % check if it is an error or in fact really NaN
          temp=eval(str,'0');
          if temp==0,
            echo on
            fprintf(1,'* error during evaluation of input\n');
            echo off
          else,
            a(i0+i2,a+j2)=NaN;
          end;
        else,
          if (size(temp)==[1 1]),
            a(i0+i2,j0+j2)=temp;
          else,
            echo on
            fprintf(1,'* input must evaluate to scalar\n');
            echo off
          end;
        end;
        set(elementvalue(i),'string',gui_str(a(i2,j2)));
      end;
      eval(['out' gui_str(i) ' = a;']);
      set(elementvalue(i),'visible','on');
      set(fig,'pointer','arrow');
    end;
  end;
end;
close;

function Str=set2on(Logic),
if Logic==1,
  Str='on';
else,
  Str='off';
end;