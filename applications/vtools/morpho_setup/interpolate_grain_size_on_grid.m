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
%Interpolate grain size distribution data on a grid. 
%
%The input grain size distribution is given in a (set of) files containing the
%cumulative grain size fractions along a polyline. If there is more than one file, 
%the data must be in order. I.e., it is assumed that the polyline of the second file
%follows the one of the first file. It is also input a (set of) grid files in which
%to interpolate the data. Finally, one needs to specify the characteristic grain 
%sizes of the model in which to interpolate. 

function interpolate_grain_size_on_grid(fpath_gsd,fpath_grd,fpath_sed,fdir_out,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'method','closest'); %closest prevents fractions largert than 1 or smaller than 0. Use `linear` with care. 

parse(parin,varargin{:});

method=parin.Results.method;

%% CALC

%load model gsd
ngsd=numel(fpath_gsd);

%read dk model 
dk_mod=D3D_read_sed(fpath_sed);

%loop on <gsd> files
frac_mod=[];
xy_gsd=[];
for kgsd=1:ngsd

    fpath_gsd_loc=fpath_gsd{kgsd};
    load(fpath_gsd_loc,'gsd');
    dsieve_mea=gsd.dk/1000;
    cum_mea=gsd.frac;

    [~,frac_mod_loc,~]=interpolate_grain_size_distribution(cum_mea,dsieve_mea,dk_mod);

    %cat
    frac_mod=cat(1,frac_mod,frac_mod_loc);
    xy_gsd=cat(1,xy_gsd,[gsd.x,gsd.y]);

end %gsd

%% check that polyline is in order

%this needs to be done manually

figure
plot(xy_gsd(:,1),xy_gsd(:,2),'-*')
axis equal

%% load all gridpoints

ng=numel(fpath_grd);

xy_grd=[];
for kg=1:ng
    gridInfo=EHY_getGridInfo(fpath_grd{kg},'XYcen');
    xy_grd=cat(1,xy_grd,[gridInfo.Xcen,gridInfo.Ycen]);
end %kg

%% interpolate on grid points

frc=z_interpolated_from_polyline(xy_grd(:,1),xy_grd(:,2),xy_gsd(:,1),xy_gsd(:,2),frac_mod(:,1:end-1),'method',method);
frc=[frc,1-sum(frc,2)];
frc(frc<1e-12)=0;
if any(frc(:)<0)
    fprintf('ups... \n')
end

%% write

simdef.mor.frac=permute(frc,[1,3,2]);
simdef.mor.frac_xy=xy_grd;
simdef.mor.thk=ones(size(xy_grd,1),1);
simdef.mor.folder_out=fdir_out;

D3D_morini_files(simdef,'check_existing',0)

end %function