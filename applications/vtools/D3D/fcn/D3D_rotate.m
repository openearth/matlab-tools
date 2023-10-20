%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%

function D3D_rotate(fpath_in,x0,y0,theta,varargin)

%% PARSE

%% CHECK TYPE

if isfolder(fpath_in) %simulation
    D3D_rotate_simulation(fpath_in,x0,y0,theta,varargin{:});
else 
    if exist(fpath_in,'file')~=2
        error('File does not exist: %s',fpath_in)
    end
    [~,~,fext]=fileparts(fpath_in);
    switch fext
        case '.nc' %grid
            D3D_rotate_grid(fpath_in,x0,y0,theta,varargin{:});
        case '.xyz' 
            D3D_rotate_xyz(fpath_in,x0,y0,theta,varargin{:});
        case '.ext'
            D3D_rotate_ext(fpath_in,x0,y0,theta,varargin{:});
        case '.pli'
            D3D_rotate_pli(fpath_in,x0,y0,theta,varargin{:});
        case '.xyn'
            D3D_rotate_xyn(fpath_in,x0,y0,theta,varargin{:});
    end %fext
end

end %function

%%
%% FUNCTIONS
%%

%%
    
function D3D_rotate_simulation(fpath_in,x0,y0,theta,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_out',fullfile(folderUp(fpath_in),'rotated'))

parse(parin,varargin{:})

fpath_out=parin.Results.fpath_out; %folder to write results

%% CALC

simdef=D3D_simpath(fpath_in);

if simdef.D3D.structure~=2
    error('Rotation of simulation only possible for FM.')
end

copyfile_check(fpath_in,fpath_out);

simdef_out=D3D_simpath(fpath_out); %the ones to modify

%% grid
D3D_rotate(simdef.file.grd,x0,y0,theta,'fpath_out',simdef_out.file.grd)

%% external
D3D_rotate(simdef.file.extforcefile,x0,y0,theta,'fpath_out',fpath_out);

%% external new
D3D_rotate(simdef.file.extforcefilenew,x0,y0,theta,'fpath_out',fpath_out);

%% obs
D3D_rotate(simdef.file.obsfile,x0,y0,theta,'fpath_out',simdef_out.file.obsfile);

end %function

%%

function D3D_rotate_grid(fpath_in,x0,y0,theta,varargin)

[fdir,fname,fext]=fileparts(fpath_in);

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_out',fullfile(fdir,sprintf('%s_rot%s',fname,fext)));

parse(parin,varargin{:})

fpath_out=parin.Results.fpath_out; %folder to write results

%% CALC

nx=ncread(fpath_in,'NetNode_x');
ny=ncread(fpath_in,'NetNode_y');

[nxr,nyr]=rotate2Dcart(nx,ny,x0,y0,theta);

ncwrite_class(fpath_out,'NetNode_x',nx,nxr);
ncwrite_class(fpath_out,'NetNode_y',ny,nyr);

end %function

%%

function D3D_rotate_xyz(fpath_in,x0,y0,theta,varargin)

[fdir,fname,fext]=fileparts(fpath_in);

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_out',fullfile(fdir,sprintf('%s_rot%s',fname,fext)));

parse(parin,varargin{:})

fpath_out=parin.Results.fpath_out; %folder to write results

%%

xyz=D3D_io_input('read',fpath_in);

[xr,yr]=rotate2Dcart(xyz(:,1),xyz(:,2),x0,y0,theta);

xyz(:,1:2)=[xr,yr];

D3D_io_input('write',fpath_out,xyz);

end %function

%%

function D3D_rotate_ext(fpath_in,x0,y0,theta,varargin)

[fdir,fname,fext]=fileparts(fpath_in);

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_out',fullfile(folderUp(fpath_in),'rotated'))

parse(parin,varargin{:})

fdir_out=parin.Results.fpath_out; %folder to write results

%% CALC

ext=D3D_io_input('read',fpath_in);
fn=fieldnames(ext);
nb=numel(fn);
for kb=1:nb
    fname_str=find_str_fname(ext.(fn{kb}));
    fname=fullfile(fdir,ext.(fn{kb}).(fname_str)); 
    fname_out=fullfile(fdir_out,ext.(fn{kb}).(fname_str)); 
    if exist(fname,'file') ~=2
        error('File does not exist: %s',fname);
    end
    D3D_rotate(fname,x0,y0,theta,'fpath_out',fname_out); 
end %kb


end %function

%%

function D3D_rotate_pli(fpath_in,x0,y0,theta,varargin)

[fdir,fname,fext]=fileparts(fpath_in);

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_out',fullfile(fdir,sprintf('%s_rot%s',fname,fext)));

parse(parin,varargin{:})

fpath_out=parin.Results.fpath_out; %folder to write results

%% CALC

pli=D3D_io_input('read',fpath_in);

npli=numel(pli);
for kpli=1:npli
    [xr,yr]=rotate2Dcart(pli(kpli).xy(:,1),pli(kpli).xy(:,2),x0,y0,theta);
    pli(kpli).xy=[xr,yr];
end %kpli

D3D_io_input('write',fpath_out,pli);

end %function

%%

function D3D_rotate_xyn(fpath_in,x0,y0,theta,varargin)

[fdir,fname,fext]=fileparts(fpath_in);

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_out',fullfile(fdir,sprintf('%s_rot%s',fname,fext)));

parse(parin,varargin{:})

fpath_out=parin.Results.fpath_out; %folder to write results

%% CALC

xyn=D3D_io_input('read',fpath_in,'version',1);
[xyn.x,xyn.y]=rotate2Dcart(xyn.x',xyn.y',x0,y0,theta);
nobs=numel(xyn.x);
xyn_out=struct('name','','x',NaN(nobs,1),'y',NaN(nobs,1));
for kobs=1:nobs
    xyn_out(kobs).name=xyn.name{kobs};
    xyn_out(kobs).x=xyn.x(kobs);
    xyn_out(kobs).y=xyn.y(kobs);
end
D3D_io_input('write',fpath_out,xyn_out);

end %function

%%

function fname_out=find_str_fname(stru)

found=false;
fname_str={'FILENAME','locationfile'};
k=0;
while ~found
    k=k+1;
    if isfield(stru,fname_str{k})
        fname_out=fname_str{k};
        found=true;
    end
end

end %function