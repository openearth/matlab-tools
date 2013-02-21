fclose all; 
clc       ;

% Enable the listboxes
set(handles.listbox1 ,'Enable','on');
set(handles.listbox2 ,'Enable','on');
set(handles.listbox3 ,'Enable','on');
set(handles.listbox4 ,'Enable','on');
set(handles.listbox5 ,'Enable','on');
set(handles.listbox7 ,'Enable','on');
set(handles.listbox8 ,'Enable','on');
set(handles.listbox9 ,'Enable','on');
set(handles.listbox10,'Enable','on');

% Empty the listboxes
set(handles.listbox1 ,'String',' ');
set(handles.listbox2 ,'String',' ');
set(handles.listbox3 ,'String',' ');
set(handles.listbox4 ,'String',' ');
set(handles.listbox5 ,'String',' ');
set(handles.listbox7 ,'String',' ');
set(handles.listbox8 ,'String',' ');
set(handles.listbox9 ,'String',' ');
set(handles.listbox10,'String',' ');

% Empty the edit boxes
set(handles.edit3,'String','');
set(handles.edit4,'String','');
set(handles.edit5,'String','');

% Select first entry
set(handles.listbox1 ,'Value',1);
set(handles.listbox2 ,'Value',1);
set(handles.listbox3 ,'Value',1);
set(handles.listbox4 ,'Value',1);
set(handles.listbox5 ,'Value',1);
set(handles.listbox7 ,'Value',1);
set(handles.listbox8 ,'Value',1);
set(handles.listbox9 ,'Value',1);
set(handles.listbox10,'Value',1);

% Enable pushbuttons
set(handles.pushbutton3 ,'Enable','on');
set(handles.pushbutton4 ,'Enable','on');
set(handles.pushbutton7 ,'Enable','on');
set(handles.pushbutton8 ,'Enable','on');

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
    set(handles.pushbutton3 ,'Enable','off');
end
if teller2 > 1;
    set(handles.listbox2 ,'String',bndfile);
else
    set(handles.listbox1    ,'Enable','off');
    set(handles.listbox2    ,'Enable','off');
    set(handles.pushbutton3 ,'Enable','off');
end
if teller3 > 1;
    set(handles.listbox3 ,'String',bctfile);
else
    set(handles.listbox3    ,'Enable','off');
    set(handles.listbox4    ,'Enable','off');
    set(handles.pushbutton4 ,'Enable','off');
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
    warndlg('No .mdf file found.','Warning');
end

% Empty the polyline listboxes
set(handles.listbox4 ,'String',' ');         % for bct-files
set(handles.listbox8 ,'String',' ');         % for bca-files
set(handles.listbox10,'String',' ');         % for bcc-files
set(handles.listbox5 ,'String',' ');         % for ext-file