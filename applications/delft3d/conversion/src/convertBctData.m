%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the bca file name has been specified (Delft3D)
filebct     = get(handles.edit11,'String');
if ~isempty(filebct);
    filebct = [pathin,'\',filebct];
    if exist(filebct,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified bct file does not exist.','Error');
        break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The bct file name has not been specified.','Error');
    break;
end

% Catch the polyline names for the boundary conditions
readpli     = get(handles.listbox1,'String');

% Filter the salinity-plis out
clear filepli;
for i=1:length(readpli);
    pli     = readpli{i};
    if strcmpi(pli(end-7:end),'_sal.pli');
        continue
    else
        filepli(i,:)  = readpli{i};
    end
end

% Read the bca-file
bctdata     = bct_io('read',filebct);


%%% ACTUAL CONVERSION OF THE BCT DATA

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
        for k=1:length(bctdata.Table);
            bcname               = bctdata.Table(k).Location;
            bcname(bcname==' ')  = [];
            if strcmpi(location(1:end-5),bcname);
                nametim          = [pathout,'\',filepli(i,1:end-4),'_',num2str(j,'%0.4d'),'.tim'];
                nametim          = fopen(nametim,'wt');
                fprintf(nametim,['* COLUMNN=2','\n']);
                fprintf(nametim,['* COLUMN1=Time (in minutes) with respect to the reference date','\n']);
                fprintf(nametim,['* COLUMN2=Quantity of the boundary condition','\n']);
                dataset          = bctdata.Table(k).Data;
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

% Fill listbox with tim files
if exist('alltimfiles');
    set(handles.listbox2,'String',alltimfiles);
    clear alltimfiles;
end