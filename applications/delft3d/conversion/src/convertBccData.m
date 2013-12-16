warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the bcc file name has been specified (Delft3D)
filebcc     = get(handles.edit14,'String');
if ~isempty(filebcc);
    filebcc = [pathin,'\',filebcc];
    if exist(filebcc,'file')==0;
        errordlg('The specified bcc file does not exist.','Error');
        break;
    end
else
    errordlg('The bcc file name has not been specified.','Error');
    break;
end

% Catch the polyline names for the boundary conditions
filepli     = get(handles.listbox1,'String');
npli        = size(filepli,1);

% Read the bcc-file
bccdata     = delft3d_io_bct('read',filebcc);


% %%% ACTUAL CONVERSION OF THE BCA DATA
% 
% % Loop over all the boundary pli-files
% for i=1:npli;
%     fid                   = fopen([pathout,'\',filepli(i,:)],'r');
%     tline                 = fgetl(fid);
%     tline                 = fgetl(fid);
%     tlinenum              = str2num(tline);
%     J                     = tlinenum(1);
%     for j=1:J;
%         tline             = fgetl(fid);
%         tline             = textscan(tline,'%s%s%s%s%s');
%         location          = cell2mat(tline{5});
%         for k=1:length(bcadata.DATA);
%             if strcmpi(location,bcadata.DATA(k).label);
%                 namecmp          = [pathout,'\',filepli(i,1:end-4),'_',num2str(j,'%0.4d'),'.cmp'];
%                 namecmp          = fopen(namecmp,'wt');
%                 fprintf(namecmp,['* COLUMNN=3','\n']);
%                 fprintf(namecmp,['* COLUMN1=Period (min) or Astronomical Componentname','\n']);
%                 fprintf(namecmp,['* COLUMN2=Amplitude (ISO)','\n']);
%                 fprintf(namecmp,['* COLUMN3=Phase (deg)','\n']);
%                 for ii=1:length(bcadata.DATA(k).names);
%                     information  = [cell2mat(bcadata.DATA(k).names(ii))     ,'    ', ...
%                                     num2str(bcadata.DATA(k).amp(ii),'%7.7f'),'    ', ...
%                                     num2str(bcadata.DATA(k).phi(ii),'%7.7f') ];
%                     fprintf(namecmp,[information,'\n']);
%                 end
%                 fclose(namecmp);
%             end
%         end
%     end
% end
% fclose all;