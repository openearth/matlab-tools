function s=xml2struct3(fname,varargin)

skiproot=1;

% Read entire file into one vector string str

fid=fopen(fname,'r');
tx=textscan(fid,'%s','delimiter','');
fclose(fid);

tx=tx{1};

nc=0;
for ii=1:length(tx)
    tx{ii}=deblank2(tx{ii});
    nc=nc+length(tx{ii});
end
str=repmat(' ',[1 nc]);
j=1;
for ii=1:length(tx)
    str(j:j+length(tx{ii})-1)=tx{ii};
    j=j+length(tx{ii});
end

% And read the nodes

s=readnode(str);

if skiproot
    fldname=fieldnames(s);
    s=s.(fldname{1}).(fldname{1});
end

%%
function s=readnode(str)

s=[];

np=0;

while 1
    np=np+1;
    
    
    skipnode=0;
    
    
    mxchar=200;
    
    mchar=min(mxchar,length(str));
    i1=strfind(str(1:mchar),'<');
    i1=i1(1);
    mchar=min(mxchar,length(str)-i1);
    i2=strfind(str(i1:i1+mchar),'>');
    i2=i2(1);
    
    name=str(i1+1:i2-1);
    isp=strfind(name,' ');
    
    if ~isempty(isp)
        % attributes
        name=name(1:isp-1);
    end
    
try 
    if isempty(name)
        skipnode=1;
        str2=[];
        i4=i2;        
    elseif name(1)=='?' || name(1)=='!'
        
        % XML info line
    
        skipnode=1;
        str2=[];
        i4=i2;        
    
    else
        
        iii=strfind(str(i2:end),['<' name '>']); % Locations of node starts
        jjj=strfind(str(i2:end),['</' name '>']); % Locations of node endings
        
        if isempty(jjj)
            disp(['No end node found for node ' name]);
        end
        
        if isempty(iii)
            % No subnodes with same name in this file
            n=1;
        elseif jjj(1)<iii(1)
            % No subnodes with same name within this node
            n=1;
        else
            % There are subnodes with same name!
            n=length(jjj);
            for k=1:length(iii)
                if jjj(k)<iii(k)
                    n=k;
                    break
                end
            end
        end
        i3=jjj(n);
        i3=i2+i3-1;
        mchar=min(mxchar,length(str)-i3);
        i4=strfind(str(i3:i3+mchar),'>');
        i4=i4(1);
        i4=i3+i4-1;
        str2=str(i2+1:i3-1);
    end
catch
    shite=1
end
    if ~skipnode
        
        inode=strfind(str2,'<');
        
        if isempty(inode)
            % End node
            if isfield(s,name)
                % Already exists
                if ~isstruct(s.(name))
                    % Make first entry a structure
                    v=s.(name);
                    s.(name)=[];
                    s.(name).(name)=v;
                end
                n=length(s.(name));
                s.(name)(n+1).(name)=str2;
            else
                s.(name)=str2;
            end
        else
            % Sub nodes found
            n=1;
            if isfield(s,name)
                n=length(s.(name))+1;
            end
            s.(name)(n).(name)=readnode(str2);
        end
        
        if i4>=length(str)
            % end of str reached
            break
        end
        
    end
    
    str=str(i4+1:end);
    
end
