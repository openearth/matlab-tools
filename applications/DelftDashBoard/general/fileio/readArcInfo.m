function varargout=readArcInfo(fname,varargin)

iinfo=0;
irows=[];
icols=[];

if ~isempty(varargin)
    for i=1:length(varargin)
        if ischar(varargin{i})
            switch lower(varargin{i})
                case{'info'}
                    iinfo=1;
                case{'rows'}
                    irows=varargin{i+1};
                case{'columns'}
                    icols=varargin{i+1};
                case{'x'}
                    xx=varargin{i+1};
                case{'y'}
                    yy=varargin{i+1};
            end
        end
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
    
    if ~isempty(irows) || ~isempty(icols)
        frewind(fid);
        nr=irows(2)-irows(1)+1;
        tic
        ztmp = textscan(fid,'',nr,'HeaderLines',irows(1)-1+6);
        toc
%         for i=1:irows(2)-irows(1)+1
%             str  = fgetl(fid);
%             ztmp(i,:) = str2num(str);
%         end
        ztmp=ztmp(:,icols(1):icols(2));
        for i=1:icols(2)-icols(1)+1
            z(:,i)=ztmp{i};
        end
        z=z';
        z(z==noval)=NaN;
        z=flipud(z);
        x=xll+cellsz*(icols(1)-1):cellsz:xll+cellsz*(icols(2)-1);
        y=yll+cellsz*(irows(1)-1):cellsz:yll+cellsz*(irows(2)-1);

    elseif ~isempty(xx) || ~isempty(yy)

        frewind(fid);

        x=xll:cellsz:(xll+(ncols-1)*cellsz);
        y=(yll+(nrows-1)*cellsz):-cellsz:yll;
        
        i1=find(y>=yy(2),1,'last');
        i2=find(y<=yy(1),1,'first');
        j1=find(x<=xx(1),1,'last');
        j2=find(x>=xx(2),1,'first');


        
%         for i=1:irows(1)-1
%             fdum=fgetl(fid);
%         end
%         f=dlmread()
        nr=i2-i1+1;
        tic
        ztmp = textscan(fid,'',nr,'HeaderLines',i1-1+6);
        toc
%         for i=1:irows(2)-irows(1)+1
%             str  = fgetl(fid);
%             ztmp(i,:) = str2num(str);
%         end
        ztmp=ztmp(:,j1:j2);
        for j=1:j2-j1+1
            z(:,j)=ztmp{j};
        end
%        z=z';
        z(z==noval)=NaN;
        z=flipud(z);
        x=x(j1:j2);
        y=y(i1:i2);
        y=fliplr(y);
    else
        z0 = textscan(fid,'%f');
        z=reshape(z0{1},ncols,nrows);
%         z=z';
        z(z==noval)=NaN;
        z=flipud(z);
        x=xll:cellsz:(xll+(ncols-1)*cellsz);
        y=(yll+(nrows-1)*cellsz):-cellsz:yll;
    end
    
    varargout{1}=x;
    varargout{2}=y;
    varargout{3}=z;
    
    fclose(fid);
    
end



