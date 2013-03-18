fclose all; 
clc       ;

% Enable the listboxes
set(handles.listbox1 ,'Enable','on');
set(handles.listbox2 ,'Enable','on');
set(handles.listbox5 ,'Enable','on');
set(handles.listbox7 ,'Enable','on');
set(handles.listbox8 ,'Enable','on');
set(handles.listbox9 ,'Enable','on');
set(handles.listbox10,'Enable','on');
set(handles.listbox11,'Enable','on');
set(handles.listbox12,'Enable','on');
set(handles.listbox13,'Enable','on');
set(handles.listbox14,'Enable','on');
set(handles.listbox15,'Enable','on');

% Empty the listboxes
set(handles.listbox1 ,'String',' ');
set(handles.listbox2 ,'String',' ');
set(handles.listbox5 ,'String',' ');
set(handles.listbox7 ,'String',' ');
set(handles.listbox8 ,'String',' ');
set(handles.listbox9 ,'String',' ');
set(handles.listbox10,'String',' ');
set(handles.listbox11,'String',' ');
set(handles.listbox12,'String',' ');
set(handles.listbox13,'String',' ');
set(handles.listbox14,'String',' ');
set(handles.listbox15,'String',' ');

% Empty the edit boxes
set(handles.edit3,'String','');
set(handles.edit4,'String','');
set(handles.edit5,'String','');
set(handles.edit6,'String','');

% Select first entry
set(handles.listbox1 ,'Value',1);
set(handles.listbox2 ,'Value',1);
set(handles.listbox5 ,'Value',1);
set(handles.listbox7 ,'Value',1);
set(handles.listbox8 ,'Value',1);
set(handles.listbox9 ,'Value',1);
set(handles.listbox10,'Value',1);
set(handles.listbox11,'Value',1);
set(handles.listbox12,'Value',1);
set(handles.listbox13,'Value',1);
set(handles.listbox14,'Value',1);
set(handles.listbox15,'Value',1);

% Enable pushbuttons
set(handles.pushbutton3 ,'Enable','on');  % bnd2pli
set(handles.pushbutton5 ,'Enable','on');  % pli2ext
set(handles.pushbutton6 ,'Enable','on');  % mdf2mdu
set(handles.pushbutton7 ,'Enable','on');  % bca2cmp
set(handles.pushbutton8 ,'Enable','on');  % bcc2tim
set(handles.pushbutton10,'Enable','on');  % grd2net
set(handles.pushbutton11,'Enable','on');  % bct2tim
set(handles.pushbutton12,'Enable','on');  % bch2cmp

% Check if the directories have been set
pathin      = get(handles.edit1,'String');
pathout     = get(handles.edit2,'String');
if isempty(pathin);
    errordlg('The input directory has not been assigned','Error');
    return;
end
if isempty(pathout);
    errordlg('The output directory has not been assigned','Error');
    return;
end
if exist(pathin,'dir')==0;
    errordlg('The input directory does not exist.','Error');
    return;
end
if exist(pathout,'dir')==0;
    errordlg('The output directory does not exist.','Error');
    return;
end

% Fill listboxes
list                = ls(pathin);
if isempty(list);
    errordlg('Directory improperly assigned.','Error');
    return;
else
    list(1:2,:)     = [];
end
teller1             = 1;
teller2             = 1;
teller3             = 1;
teller4             = 1;
teller5             = 1;
teller6             = 1;
teller7             = 1;
teller8             = 1;
for i=1:size(list,1);
    file            = list(i,:);
    file(file==' ') = [];
    if length(file)>4;
        switch file(end-3:end);
            case '.grd';
                grdfile(teller1,:) = list(i,:);
                teller1            = teller1 + 1;
            case '.bnd';
                bndfile(teller2,:) = list(i,:);
                teller2            = teller2 + 1;
            case '.bct';
                bctfile(teller3,:) = list(i,:);
                teller3            = teller3 + 1;
            case '.bca';
                bcafile(teller4,:) = list(i,:);
                teller4            = teller4 + 1;
            case '.bch';
                bchfile(teller7,:) = list(i,:);
                teller7            = teller7 + 1;
            case '.dep';
                depfile(teller8,:) = list(i,:);
                teller8            = teller8 + 1;
            case '.bcc';
                bccfile(teller5,:) = list(i,:);
                teller5            = teller5 + 1;
            case '.mdf';
                mdffile(teller6,:) = list(i,:);
                teller6            = teller6 + 1;
        end
    end
end

% Put the filenames in the listboxes
if teller1 > 1;
    set(handles.listbox1 ,'String',grdfile);
else
    set(handles.listbox1    ,'Enable','off');
    set(handles.listbox2    ,'Enable','off');
    set(handles.listbox11   ,'Enable','off');
    set(handles.pushbutton3 ,'Enable','off');
    set(handles.pushbutton10,'Enable','off');
end
if teller2 > 1;
    set(handles.listbox2 ,'String',bndfile);
else
    set(handles.listbox2    ,'Enable','off');
    set(handles.pushbutton3 ,'Enable','off');
end
if teller3 > 1;
    set(handles.listbox12,'String',bctfile);
else
    set(handles.listbox12   ,'Enable','off');
    set(handles.listbox13   ,'Enable','off');
    set(handles.pushbutton11,'Enable','off');
end
if teller4 > 1;
    set(handles.listbox7 ,'String',bcafile);
else
    set(handles.listbox7    ,'Enable','off');
    set(handles.listbox8    ,'Enable','off');
    set(handles.pushbutton7 ,'Enable','off');
end
if teller5 > 1;
    set(handles.listbox9 ,'String',bccfile);
else
    set(handles.listbox9    ,'Enable','off');
    set(handles.listbox10   ,'Enable','off');
    set(handles.pushbutton8 ,'Enable','off');
end
if teller6 > 1;
    set(handles.edit4,'String',mdffile(1,:));
else
    set(handles.pushbutton5 ,'Enable','off');
    set(handles.pushbutton6 ,'Enable','off');
    warndlg('No .mdf file found.','Warning');
end
if teller7 > 1;
    set(handles.listbox14,'String',bchfile);
else
    set(handles.listbox14   ,'Enable','off');
    set(handles.listbox15   ,'Enable','off');
    set(handles.pushbutton12,'Enable','off');
end
if teller8 > 1;
    set(handles.listbox11,'String',depfile);
else
    set(handles.listbox11   ,'Enable','off');
end

% Empty the polyline listboxes
set(handles.listbox13,'String',' ');         % for bct-files
set(handles.listbox8 ,'String',' ');         % for bca-files
set(handles.listbox15,'String',' ');         % for bch-files
set(handles.listbox10,'String',' ');         % for bcc-files
set(handles.listbox5 ,'String',' ');         % for ext-file