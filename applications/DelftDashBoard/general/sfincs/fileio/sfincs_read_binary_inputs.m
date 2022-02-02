function [z,msk,rgh,qinf]=sfincs_read_binary_inputs(mmax,nmax,indexfile,bindepfile,binmskfile,varargin)

rghfile=[];
qinffile=[];
rghv=[];
qinfv=[];
rgh=[];
qinf=[];
z=[];

if length(varargin)==1
    rghfile=varargin{1};
end
if length(varargin)==2
    rghfile=varargin{1};
    qinffile=varargin{2};
end

% Reads binary input files for SFINCS

z=zeros(nmax,mmax);
z(z==0)=NaN;
msk=z;

if ~isempty(rghfile)
    rgh=z;
end
if ~isempty(qinffile)
    qinf=z;
end

% Read index file
fid=fopen(indexfile,'r');
np=fread(fid,1,'integer*4');
indices=fread(fid,np,'integer*4');
fclose(fid);

% Read mask file
fid=fopen(binmskfile,'r');
mskv=fread(fid,np,'integer*1');
fclose(fid);
msk(indices)=mskv;

if ~isempty(bindepfile)
    % Read depth file
    if exist(bindepfile,'file')
        fid=fopen(bindepfile,'r');
        zbv=fread(fid,np,'real*4');
        fclose(fid);
        z(indices)=zbv;
    end
end

if ~isempty(rghfile)
    % Read depth file
    fid=fopen(rghfile,'r');
    rghv=fread(fid,np,'real*4');
    fclose(fid);
    rgh(indices)=rghv;
end
if ~isempty(qinffile)
    % Read depth file
    fid=fopen(qinffile,'r');
    qinfv=fread(fid,np,'real*4');
    fclose(fid);
    qinf(indices)=qinfv;
end
