function varargout=readArcInfo(fname,varargin)

iinfo=0;

if ~isempty(varargin)
    switch lower(varargin{1})
        case{'info'}
            iinfo=1;
    end
end

if iinfo
    
    fid=fopen(fname,'r');
    
    str=fgets(fid);
    ncols=str2double(str(6:end));
    str=fgets(fid);
    nrows=str2double(str(6:end));
    str=fgets(fid);
    xll=str2double(str(10:end));
    str=fgets(fid);
    yll=str2double(str(10:end));
    str=fgets(fid);
    cellsz=str2double(str(9:end));
    str=fgets(fid);
    noval=str2double(str(13:end));
    
    fclose(fid);
    
    varargout{1}=ncols;
    varargout{2}=nrows;
    varargout{3}=xll;
    varargout{4}=yll;
    varargout{5}=cellsz;
    
else
    
    fid=fopen(fname,'r');
    
    str=fgets(fid);
    ncols=str2double(str(6:end));
    str=fgets(fid);
    nrows=str2double(str(6:end));
    str=fgets(fid);
    xll=str2double(str(10:end));
    str=fgets(fid);
    yll=str2double(str(10:end));
    str=fgets(fid);
    cellsz=str2double(str(9:end));
    str=fgets(fid);
    noval=str2double(str(13:end));
    
    z0 = textscan(fid,'%f');
    
    fclose(fid);
    
    z=reshape(z0{1},ncols,nrows);
    z=z';
    z(z==noval)=NaN;
    z=flipud(z);
    
    x=xll:cellsz:(xll+(ncols-1)*cellsz);
    y=(yll+(nrows-1)*cellsz):-cellsz:yll;
    
    varargout{1}=x;
    varargout{2}=y;
    varargout{3}=z;
    
end



