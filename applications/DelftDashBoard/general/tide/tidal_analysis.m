function [cmp,amp,phi,tt,xout]=tidal_analysis(t0,z0,varargin)

latitude=[];
constituents=[];
dt=30; % minutes
outputfile=[];
writetek=0;
writemat=0;
name=[];
longname=[];
id=[];
x=[];
y=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'components','constituents'}
                constituents=varargin{ii+1};
            case{'latitude'}
                latitude=varargin{ii+1};
            case{'dt'}
                dt=varargin{ii+1};
            case{'outputfile'}
                outputfile=varargin{ii+1};
            case{'tekal','tek'}
                writetek=1;
            case{'mat'}
                writemat=1;
            case{'name'}
                name=varargin{ii+1};
            case{'longname'}
                longname=varargin{ii+1};
            case{'id'}
                id=varargin{ii+1};
            case{'x'}
                x=varargin{ii+1};
            case{'y'}
                y=varargin{ii+1};
        end
    end
end

% Interpolate time series
tt=t0(1):dt/1440:t0(end);
zz=interpolatetimeseries(t0,z0,tt);

if ~isempty(latitude)
    [tidestruc,xout]=t_tide(zz,'starttime',tt(1),'interval',dt/60,'latitude',latitude,'error','wboot');
%    [tidestruc,xout]=t_tide(zz,'starttime',tt(1),'interval',dt/60,'latitude',latitude);
else
    [tidestruc,xout]=t_tide(zz,'starttime',tt(1),'interval',dt/60,'error','wboot');
end

amp=[];
phi=[];
cmp=[];

if ~isempty(constituents)
    % Use selected components
    for j=1:length(constituents)
        cmp{j}=constituents{j};
        amp(j)=0;
        phi(j)=0;
        for ii=1:length(tidestruc.freq)
            if strcmpi(deblank2(tidestruc.name(ii,:)),constituents{j})
                amp(j)=tidestruc.tidecon(ii,1);
                phi(j)=tidestruc.tidecon(ii,3);
                break
            end
        end
    end
else
    % Use all components
    for ii=1:length(tidestruc.freq)
        cmp{ii}=deblank2(tidestruc.name(ii,:));
        amp(ii)=tidestruc.tidecon(ii,1);
        phi(ii)=tidestruc.tidecon(ii,3);
    end
end

% Save data to tek file
if writetek
    
    fname=outputfile;
    if ~strcmpi(outputfile(end-2:end),'tek')
        fname=[outputfile '.tek'];
    end
    
    fid=fopen(fname,'wt');
    fprintf(fid,'%s\n','* column 1 : Amplitude');
    fprintf(fid,'%s\n','* column 2 : Phase');
    fprintf(fid,'%s\n','* column 3 : Component name');
    fprintf(fid,'%s\n','BL01');
    fprintf(fid,'%i %i\n',length(cmp),3);
    for ii=1:length(cmp)
        fprintf(fid,'%9.4f %8.2f %s\n',amp(ii),phi(ii),cmp{ii});
    end
    fclose(fid);
    
end

% Save data to tek file
if writemat
    
    fname=outputfile;
    if ~strcmpi(outputfile(end-2:end),'mat')
        fname=[outputfile '.mat'];
    end
    
    s.station.name=name;
    s.station.id=id;
    s.station.longname=longname;
    s.station.x=x;
    s.station.y=y;
    s.station.component=cmp;
    s.station.amplitude=amp;
    s.station.phase=phi;
    
    save(fname,'-struct','s');
        
end

% constituents={'M2','S2','N2','K2','K1','O1','P1','Q1','MM','MSF'};

