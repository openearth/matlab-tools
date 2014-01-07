warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the bca file name has been specified (Delft3D)
filebca     = get(handles.edit12,'String');
if ~isempty(filebca);
    filebca = [pathin,'\',filebca];
    if exist(filebca,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified bca file does not exist.','Error');
        break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The bca file name has not been specified.','Error');
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
bcadata     = delft3d_io_bca('read',filebca);


%%% ACTUAL CONVERSION OF THE BCA DATA

% Loop over all the boundary pli-files
npli        = size(filepli,1);
cnt         = 1;
for i=1:npli;
    fid                   = fopen([pathout,'\',filepli(i,:)],'r');
    tline                 = fgetl(fid);
    tline                 = fgetl(fid);
    tlinenum              = str2num(tline);
    J                     = tlinenum(1);                  % number of pli-points
    for j=1:J;
        tline             = fgetl(fid);
        tline             = textscan(tline,'%s%s%s%s%s');
        location          = cell2mat(tline{5});
        for k=1:length(bcadata.DATA);
            if strcmpi(location,bcadata.DATA(k).label);
                namecmp            = [pathout,'\',filepli(i,1:end-4),'_',num2str(j,'%0.4d'),'.cmp'];
                namecmp            = fopen(namecmp,'wt');
                fprintf(namecmp,['* COLUMNN=3','\n']);
                fprintf(namecmp,['* COLUMN1=Period (min) or Astronomical Componentname','\n']);
                fprintf(namecmp,['* COLUMN2=Amplitude (ISO)','\n']);
                fprintf(namecmp,['* COLUMN3=Phase (deg)','\n']);
                for ii=1:length(bcadata.DATA(k).names);
                    information    = [cell2mat(bcadata.DATA(k).names(ii))     ,'    ', ...
                                      num2str(bcadata.DATA(k).amp(ii),'%7.7f'),'    ', ...
                                      num2str(bcadata.DATA(k).phi(ii),'%7.7f') ];
                    fprintf(namecmp,[information,'\n']);
                end
                allcmpfiles(cnt,:) = [filepli(i,1:end-4),'_',num2str(j,'%0.4d'),'.cmp'];
                cnt                = cnt + 1;
                fclose(namecmp);
            end
        end
    end
end
fclose all;

% Fill listbox with cmp files
if exist('allcmpfiles');
    set(handles.listbox3,'String',allcmpfiles);
    clear allcmpfiles;
end