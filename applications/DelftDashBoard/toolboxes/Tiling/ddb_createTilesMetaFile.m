function ddb_createTilesMetaFile(dr,dataname,nrzoom,dxk,dyk,nnxk,nnyk,nxk,nyk,x0,y0,OPT)

for k=1:nrzoom
    nnx=nnxk(k);
    nny=nnyk(k);
    nav=0;
    
    flist2=dir([dr 'zl' num2str(k,'%0.2i') '\*.nc']);
    iin=[];
    jin=[];
    for jjj=1:length(flist2)
        iin(jjj)=str2double(flist2(jjj).name(end-13:end-9));
        jin(jjj)=str2double(flist2(jjj).name(end-7:end-3));
    end
    
    for i=1:nnx
        for j=1:nny
            iava=find(iin==i & jin==j, 1);
            if ~isempty(iava)
                nav=nav+1;
                iavailable{k}(nav)=i;
                javailable{k}(nav)=j;
            end
        end
    end
end
fnamemeta=[dr dataname '.nc'];
nc_createNCmetafile(fnamemeta,x0,y0,dxk,dyk,nnxk,nnyk,nxk,nyk,iavailable,javailable,OPT);
