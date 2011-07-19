delete('bin\*');

statspath='Y:\app\MATLAB2009b\toolbox\stats';
rmpath(statspath);

mkdir('qptmp');
copyfile('F:\checkout\opendelft3d\trunk\src\tools_lgpl\matlab\quickplot\progsrc\private\*.m','qptmp');
copyfile('F:\checkout\opendelft3d\trunk\src\tools_lgpl\matlab\quickplot\progsrc\*.m','qptmp');
addpath('qptmp');
%flist=dir('F:\checkout\opendelft3d\trunk\src\tools_lgpl\matlab\quickplot\progsrc\private\*fil.m');

fid=fopen('complist','wt');

fprintf(fid,'%s\n','-a');

% for i=1:length(flist)
%     switch flist(i).name
%         case{'.','..','.svn'}
%         otherwise
%             fname=flist(i).name;
%             fprintf(fid,'%s\n',fname);
%     end
% end

filetypes=defineFileTypes;
nf=size(filetypes,1);
for i=1:nf
    fprintf(fid,'%s\n',['AddDataset' filetypes{i,2}]);    
end

fclose(fid);

mcc -m -d F:\checkout\OpenEarthTools\trunk\matlab\applications\muppet\bin muppet.m -B complist

delete('complist');

delete('qptmp\*.m');
rmpath('qptmp');
rmdir('qptmp','s');
