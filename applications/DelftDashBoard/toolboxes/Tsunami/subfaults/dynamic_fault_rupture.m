function dynamic_fault_rupture(varargin)

subfaults=[];
subfaultfile=[];
sdufile=[];
inifile=[];
dx=60;
dt=5;
refdate=[];
kmax=1;
nconstituents=0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'subfaults'}
                subfaults=varargin{ii+1};
            case{'subfaultfile'}
                subfaultfile=varargin{ii+1};
            case{'dx'}
                dx=varargin{ii+1};
            case{'sdufile'}
                sdufile=varargin{ii+1};
            case{'inifile'}
                inifile=varargin{ii+1};
            case{'kmax'}
                kmax=varargin{ii+1};
            case{'nconstituents'}
                nconstituents=varargin{ii+1};
            case{'grdfile'}
                grdfile=varargin{ii+1};
            case{'xz'}
                xz=varargin{ii+1};
            case{'yz'}
                yz=varargin{ii+1};
            case{'dt'}
                dt=varargin{ii+1};
            case{'refdate'}
                refdate=varargin{ii+1};
            case{'xlim'}
                xlower = varargin{ii+1}(1);
                xupper = varargin{ii+1}(2);
            case{'ylim'}
                ylower = varargin{ii+1}(1);
                yupper = varargin{ii+1}(2);
        end
    end
end

if ~isempty(subfaultfile)
    % Read in subfaults file
    path = '';
    subfaults = read_subfault('path',fullfile(path,subfaultfile));
end

if isempty(subfaults)
    error('Please provide subfaults structure or name for subfaults file!');
end

% Read Delft3D grid
if ~isempty(grdfile)
    [xg,yg]=wlgrid('read',grdfile);
    [xz,yz]=getXZYZ(xg,yg);
end

if isempty(xz)
    error('Please provide grid coordinates or name for Delft3D grid file!');
end

% Discretize grid
gridsize = dx; % in arcseconds
mx = int16((xupper-xlower)*(3600/gridsize) + 1); 
my = int16((yupper-ylower)*(3600/gridsize) + 1);
x = linspace(xlower,xupper,mx);
y = linspace(ylower,yupper,my);

% Calculate the combined deformation from all the subfaults using Okada
nsub=length(subfaults.dip);
dzfinal=zeros(nsub,length(y),length(x));
for isub=1:nsub
    [X,Y,DZ,times] = okada(subfaults, x, y, 'subfaultnumber', isub);
    dzfinal(isub,:,:)=DZ;
end

%% SDU file

if ~isempty(sdufile)
    
    % Determine times in sdu file
    tmin=min(subfaults.rupture_time) + dt; % start time sdu file
    tmax=max(subfaults.rupture_time + subfaults.rise_time(isub) + subfaults.rise_time_ending);
    nt=ceil((tmax-tmin)/dt)+1;             % number of time steps in sdu file
    tmax=tmin+(nt-1)*dt;                 % end time in sdu file
    
    % Pre-allocate array dz_dynamic
    dz_dynamic=zeros(nt,length(y),length(x));
    % Loop through times in sdu file
    disp('Looping through time steps ...');
    for it=1:nt
        times(it)=tmin+(it-1)*dt;
        dzt=zeros(length(y),length(x));
        for isub=1:nsub
            % Determine the state of each subfault at this time
            if times(it)<=subfaults.rupture_time(isub)
                % Not ruptured yet
            elseif times(it)<=subfaults.rupture_time(isub) + subfaults.rise_time(isub) + subfaults.rise_time_ending(isub)
                % Rupturing now
                % Determine rise fraction
                rf=rise_fraction(times(it), subfaults.rupture_time(isub), subfaults.rise_time(isub), subfaults.rise_time_ending(isub));
                dzt=dzt+rf*squeeze(dzfinal(isub,:,:));
            else
                % Already ruptured
                dzt=dzt+squeeze(dzfinal(isub,:,:));
            end
        end
        dz_dynamic(it,:,:)=dzt;
    end
    
    % Now interpolate data onto Delft3D grid
    % Pre-allocate array dz_dynamic
    
    dzd3d=zeros(nt,size(xz,1),size(xz,2));
    
    fid=fopen(sdufile,'wt');
    
    fprintf(fid,'%s\n','### START OF HEADER');
    fprintf(fid,'%s\n','### All text on a line behind the first # is parsed as commentary');
    fprintf(fid,'%s\n','### Additional commments');
    fprintf(fid,'%s\n','FileVersion      =    1.03                                              # Version of meteo input file, to check if the newest file format is used');
    fprintf(fid,'%s\n','filetype         =    field_on_computational_grid                       # Type of input file: field_on_computational_grid');
    fprintf(fid,'%s\n','NODATA_value     =    -999                                              # Value used for undefined or missing data');
    fprintf(fid,'%s\n','n_quantity       =    1                                                  # Number of quantities prescribed in the file');
    fprintf(fid,'%s\n','quantity1        =    bedrock_surface_elevation                          # Name of quantity1');
    fprintf(fid,'%s\n','unit1            =    m                                                  # Unit of quantity1');
    fprintf(fid,'%s\n','### END OF HEADER');
    
    disp('Interpolating onto Delft3D grid ...');
    for it=1:nt
        dzt=squeeze(dz_dynamic(it,:,:));
        block=zeros(size(xz,1)+1,size(xz,2)+1);
        %    block(block==0)=NaN;
        dzd3d=interp2(X,Y,dzt,xz,yz);
        dzd3d(isnan(dzd3d))=0.0;
        block(1:end-1,1:end-1)=dzd3d;
        str=['TIME             = ' num2str(times(it)/60) ' minutes since ' datestr(refdate,'yyyy-mm-dd') ' 00:00:00 +00:00'];
        fprintf(fid,'%s\n',str);
        writeblock(fid,block,'%12.3f');
    end
    str=['TIME             = ' num2str(10000) ' minutes since ' datestr(refdate,'yyyy-mm-dd') ' 00:00:00 +00:00'];
    fprintf(fid,'%s\n',str);
    writeblock(fid,block,'%12.3f');
    
    fclose(fid);
    
end

%% INI file

if ~isempty(inifile)
    
    % Add final displacements from all subfaults
    dzt=zeros(length(y),length(x));
    for isub=1:nsub
        dzt=dzt+squeeze(dzfinal(isub,:,:));
    end
    
    % Now interpolate data onto Delft3D grid
    % Pre-allocate array dz_dynamic
    
    fid=fopen(inifile,'wt');
    
    block0=zeros(size(xz,1)+1,size(xz,2)+1);
    block=block0;
    dzd3d=interp2(X,Y,dzt,xz,yz);
    dzd3d(isnan(dzd3d))=0.0;
    block(1:end-1,1:end-1)=dzd3d;
    writeblock(fid,block,'%12.3f');
    for k=1:kmax
        % U
        writeblock(fid,block0,'%12.3f');
        % V
        writeblock(fid,block0,'%12.3f');
    end
    for ic=1:nconstituents
        for k=1:kmax
            writeblock(fid,block0,'%12.3f');
        end
    end
    
    fclose(fid);
    
end


%%
function writeblock(fid,DP,format)

DP(isnan(DP))=-999;

lformat = length(format)+2;
Frmt=repmat([format '  '],[1 size(DP,1)]);
k=lformat*12;
Frmt((k-1):k:length(Frmt))='\';
Frmt(k:k:length(Frmt))='n';
Frmt(end-1:end)='\n';
Frmt=strrep(Frmt,'  ',' ');

szDP=size(DP);
if length(szDP)<3
    kmax=1;
else
    kmax=prod(szDP(3:end));
end
for k=1:kmax
    fprintf(fid,Frmt,DP(:,:,k));
end

