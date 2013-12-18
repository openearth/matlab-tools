warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the bcc file name has been specified (Delft3D)
filebcc     = get(handles.edit14,'String');
if ~isempty(filebcc);
    filebcc = [pathin,'\',filebcc];
    if exist(filebcc,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified bcc file does not exist.','Error');
        break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The bcc file name has not been specified.','Error');
    break;
end

% Catch the polyline names for the boundary conditions
readpli     = get(handles.listbox1,'String');

% Filter the salinity-plis in
clear filepli;
n           = 1;
for i=1:length(readpli);
    pli     = readpli{i};
    if ~strcmpi(pli(end-7:end),'_sal.pli');
        continue
    else
        filepli(n,:)  = readpli{i};
        n             = n + 1;
    end
end

% Read the bcc-file
bccdata     = bct_io('read',filebcc);

% Loop over all the boundary pli-files
npli        = size(filepli,1);
cnt         = 1;
for i=1:npli;
    fid                   = fopen([pathout,'\',filepli(i,:)],'r');
    tline                 = fgetl(fid);
    tline                 = fgetl(fid);
    tlinenum              = str2num(tline);
    J                     = tlinenum(1);
    for j=1:J;
        tline             = fgetl(fid);
        tline             = textscan(tline,'%s%s%s%s%s');
        location          = cell2mat(tline{5});
        for k=1:length(bccdata.Table);
            bcname               = bccdata.Table(k).Location;
            bctype               = bccdata.Table(k).Parameter(end).Name(1:8);
            bcname(bcname==' ')  = [];
            if strcmpi(location(1:end-5),bcname) & strcmpi(bctype,'Salinity');
                nametim          = [pathout,'\',filepli(i,1:end-4),'_',num2str(j,'%0.4d'),'.tim'];
                nametim          = fopen(nametim,'wt');
                fprintf(nametim,['* COLUMNN=2','\n']);
                fprintf(nametim,['* COLUMN1=Time (in minutes) with respect to the reference date','\n']);
                fprintf(nametim,['* COLUMN2=Salinity (in ppt)','\n']);
                dataset          = bccdata.Table(k).Data;
                if strcmpi(location(end),'a');
                    w            = 2;
                end
                if strcmpi(location(end),'b');
                    w            = 3;
                    if dataset(1,w) == 9.9999900e+002 | dataset(1,w) == 9.99e+002;
                        w        = 2;
                    end
                end
                if strcmpi(tline{3},'t');
                    for ii=1:size(dataset,1);
                        information  = [num2str(    dataset(ii,1) ,'%7.7f'),'    ', ...
                                        num2str(abs(dataset(ii,w)),'%7.7f')];
                        fprintf(nametim,[information,'\n']);
                    end
                else
                    for ii=1:size(dataset,1);
                        information  = [num2str(dataset(ii,1)     ,'%7.7f'),'    ', ...
                                        num2str(dataset(ii,w)     ,'%7.7f')];
                        fprintf(nametim,[information,'\n']);
                    end
                end
                alltimfiles(cnt,:) = [filepli(i,1:end-4),'_',num2str(j,'%0.4d'),'.tim'];
                cnt                = cnt + 1;
                fclose(nametim);
            end
        end
    end
end
fclose all;
set(handles.listbox5,'String',alltimfiles);