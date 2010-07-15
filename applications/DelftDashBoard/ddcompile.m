delete('exe\*');

fid=fopen('complist','wt');

fprintf(fid,'%s\n','-a');

fprintf(fid,'%s\n','DelftDashBoard.m');

% Add models
flist=dir('models');
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        otherwise
            f=dir(['models\' flist(i).name '\main\*.m']);
            for j=1:length(f)
                fname=f(j).name;
                switch fname
                    case{'.','..','.svn'}
                    otherwise
                        fprintf(fid,'%s\n',fname);
                end
            end
    end
end

% Add toolboxes
flist=dir('toolboxes');
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        otherwise
            fname=flist(i).name;
            fprintf(fid,'%s\n',['ddb_' fname 'Toolbox.m']);
            fprintf(fid,'%s\n',['ddb_Plot' fname '.m']);
            fprintf(fid,'%s\n',['ddb_initialize' fname '.m']);
    end
end

% Add model specific toolbox functions
flist=dir('models');
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        otherwise
            flist2=dir(['models\' flist(i).name '\toolbox\']);
            for ij=1:length(flist2)
                switch flist2(ij).name
                    case{'.','..','.svn'}
                    otherwise
                        f=dir(['models\' flist(i).name '\toolbox\' flist2(ij).name '\*.m']);
                        for j=1:length(f)
                            fname=f(j).name;
                            switch fname
                                case{'.','..','.svn'}
                                otherwise
                                    fprintf(fid,'%s\n',fname);
                            end
                        end
                end
            end
    end
end

fclose(fid);

mcc -m -d exe DelftDashBoard.m -B complist
 
delete('complist');
