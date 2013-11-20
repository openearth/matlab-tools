warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the bca file name has been specified (Delft3D)
filebct     = get(handles.edit11,'String');
if isempty(filebct);
    errordlg('The bct file name has not been specified.','Error');
    return;
end

% Put the output directory name in the filenames
filebct     = [pathin ,'\',filebct];

% Catch the polyline names for the boundary conditions
filepli     = get(handles.listbox1,'String');
npli        = size(filepli,1);

% Read the bca-file
bctdata     = bct_io('read',filebct);


%%% ACTUAL CONVERSION OF THE BCT DATA

% Loop over all the boundary pli-files
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
            if strcmpi(location(1:end-1),bctdata.Table(k).Location);
                nametim          = [pathout,'\',filepli(i,1:end-4),'_',num2str(j,'%0.4d'),'.tim'];
                nametim          = fopen(nametim,'wt');
                fprintf(nametim,['* COLUMNN=3','\n']);
                fprintf(nametim,['* COLUMN1=Period (min) or Astronomical Componentname','\n']);
                fprintf(nametim,['* COLUMN2=Amplitude (ISO)','\n']);
                fprintf(nametim,['* COLUMN3=Phase (deg)','\n']);
                dataset          = bctdata.Table(k).Data;
                if strcmpi(location(end),'a');
                    w            = 2;
                end
                if strcmpi(location(end),'b');
                    w            = 3;
                    if dataset(1,w) == 9.9999900e+002;
                        w        = 2;
                    end
                end
                for ii=1:size(dataset,1);
                    information  = [num2str(dataset(ii,1),'%7.7f'),'    ', ...
                                    num2str(dataset(ii,w),'%7.7f'),'    ', ...
                                    num2str(0.0          ,'%7.7f')];
                    fprintf(nametim,[information,'\n']);
                end
                alltimfiles(cnt,:) = [filepli(i,1:end-4),'_',num2str(j,'%0.4d'),'.tim'];
                cnt                = cnt + 1;
                fclose(nametim);
            end
        end
    end
end
fclose all;
set(handles.listbox2,'String',alltimfiles);