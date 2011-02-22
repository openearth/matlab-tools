function ddb_saveDDBoundFile(bndind,fname)

nddb=length(bndind);
if nddb>0
    % Write DDBOUND file
    fid = fopen(fname,'wt');
    for i=1:nddb
        runid1=bndind(i).runid1;
        runid2=bndind(i).runid2;
        r1str=[runid1 '.mdf' repmat(' ',1,10-length(runid1))];
        r2str=[runid2 '.mdf' repmat(' ',1,10-length(runid2))];
            fprintf(fid,'%s %8i %8i %8i %8i %s %8i %8i %8i %8i\n',r1str,bndind(i).m1a,bndind(i).n1a,bndind(i).m1b,bndind(i).n1b,r2str,bndind(i).m2a,bndind(i).n2a,bndind(i).m2b,bndind(i).n2b);
    end
    fclose(fid);
end
