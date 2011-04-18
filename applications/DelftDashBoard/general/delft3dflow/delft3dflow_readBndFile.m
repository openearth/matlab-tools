function openBoundaries=delft3dflow_readBndFile(fname)

fid=fopen(fname);

n=0;
openBoundaries=[];

for i=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        n=n+1;
        
        % Defaults
        openBoundaries(n).compA='unnamed';
        openBoundaries(n).compB='unnamed';
        openBoundaries(n).profile='Uniform';
        
        v=strread(tx0(22:end),'%q');
        openBoundaries(n).M1=str2double(v{3});
        openBoundaries(n).N1=str2double(v{4});
        openBoundaries(n).M2=str2double(v{5});
        openBoundaries(n).N2=str2double(v{6});
        openBoundaries(n).name=deblank(tx0(1:21));
        openBoundaries(n).type=v{1};
        openBoundaries(n).forcing=v{2};
        openBoundaries(n).alpha=str2double(v{7});
        ii=8;
        switch openBoundaries(n).type
            case{'C','Q','T','R'}
                openBoundaries(n).profile=v{8};
                ii=9;
            otherwise
                openBoundaries(n).profile='Uniform';
        end
        switch openBoundaries(n).forcing
            case{'A'}
                openBoundaries(n).compA=v{ii};
                openBoundaries(n).compB=v{ii+1};
        end
    end
end

fclose(fid);
