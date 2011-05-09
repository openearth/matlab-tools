delete('bin\*');

flist=dir(['D:\muppet\Muppet_v3.19\src\wl\wl_quickplot\private\*fil.m' ]);

fid=fopen('complist','wt');

fprintf(fid,'%s\n','-a');

for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        otherwise
            fname=flist(i).name;
            fprintf(fid,'%s\n',fname);
    end
end

fclose(fid);


mcc -m -d bin muppet.m -B complist

delete('complist');
