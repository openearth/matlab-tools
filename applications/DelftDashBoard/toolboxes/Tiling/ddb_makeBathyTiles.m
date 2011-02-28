function ddb_makeBathyTiles(dr,dataname,ncfiles,nrzoom,x00,y00,dx0,dy0,npx,npy,nx,ny,OPT)

dr=[dr dataname filesep];

imaketiles=1;
imakemeta=1;

x0(1)=x00;
y0(1)=y00;
dxk(1)=dx0;
dyk(1)=dy0;
nnxk(1)=ceil(npx/nx);
nnyk(1)=ceil(npy/ny);
nxk(1)=nx;
nyk(1)=ny;

for k=2:nrzoom
    x0(k)=x00;
    y0(k)=y00;
    dxk(k)=dxk(1)*2^(k-1);
    dyk(k)=dyk(1)*2^(k-1);
    nnxk(k)=ceil(nnxk(k-1)/2);
    nnyk(k)=ceil(nnyk(k-1)/2);
    nxk(k)=nx;
    nyk(k)=ny;
end

izoomstart=6;
izoomstop=nrzoom;

if imaketiles
    
    
%    ddb_makeLowLevelTiles(dr,dataname,ncfiles,dxk,dyk,nnxk,nnyk,nxk,nyk,x0,y0,OPT);
    
    for k=izoomstart:izoomstop
        ddb_makeHighLevelTiles(dr,dataname,k,dxk,dyk,nnxk,nnyk,x0,y0,nxk,nyk,OPT);
    end
    
end
    
% Check which files are available and make meta file
if imakemeta
    ddb_createTilesMetaFile(dr,dataname,nrzoom,dxk,dyk,nnxk,nnyk,nxk,nyk,x0,y0,OPT);
end
