function ExportFigure(handles,ifig,mode)

try
    if strcmp(mode,'guiexport')
        wb = waitbox('Exporting figure...');
    elseif strcmp(mode,'print')
        wb = waitbox('Printing figure...');
    end

    MakeFigure(handles,ifig,mode);

    if strcmp(mode,'print')
        ii=printdlg('-setup',gcf);
    else
        fid=fopen(handles.Figure(ifig).FileName,'w');
        if fid~=-1
            fclose(fid);
        end
        if fid==-1
            txt=strvcat(['The file ' handles.Figure(ifig).FileName ' cannot be opened'],'Remove write protection');
            GiveWarning('WarningText',txt);
        else
            % Export figure
            if strcmpi(handles.Figure(ifig).Orientation,'l')
                 set(gcf,'PaperOrientation','landscape');
            end
            print (gcf,['-d' handles.Figure(ifig).Format],['-r' num2str(handles.Figure(ifig).Resolution)], ...
                ['-' lower(handles.Figure(ifig).Renderer)], ...
                handles.Figure(ifig).FileName);

            if strcmpi(handles.Figure(ifig).BackgroundColor,'none')
                a=imread(handles.Figure(ifig).FileName);
                itransp=real(sum(a,3)~=612);
%                 imwrite(a,handles.Figure(ifig).FileName,'transparency',squeeze(double(a(1,1,:))/255));
                imwrite(a,handles.Figure(ifig).FileName,'alpha',itransp);
            end

        end
    end
catch
    h=findobj('Tag','waitbox');
    close(h);
    err=lasterror;
    str{1}=['An error occured in function: '  err.stack(1).name];
    str{2}=['Error: '  err.message];
    str{3}=['File: ' err.stack(1).file];
    str{4}=['Line: ' num2str(err.stack(1).line)];
    str{5}=['See muppet.err for more information'];
    strv=strvcat(str{1},str{2},str{3},str{4},str{5});
    if strcmp(mode,'guiexport')
        uiwait(errordlg(strv,'Error','modal'));
    end
    WriteErrorLog(err);
end
if exist('wb') && ishandle(wb)
    close(wb);
end
if ishandle(999)
    close(999);
end
