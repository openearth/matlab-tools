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
%Interpolate bed levels on a grid.
%
%There are two options:
%   1. Provide a shapefile and Excel file together with a year. 
%   2. Provide a shapefile and a dbf-file with the data for a year.
%
%INPUT:
%   -fpath_shp: shapefile.
%   -fpath_data: Excel or dbf-file.
%   -fpath_grd: netcdf-file with the grid.
%
%PAIR-INPUT:
%   -Option 1:
%       -xlsx_range (optional): range to read from the Excel file.
%       -year (compulsory): year for which data is needed.
%   -Option 2:

function interpolate_bed_level_from_xlsx(fpath_shp,fpath_data,fpath_grd,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'xlsx_range','');
addOptional(parin,'year','');
addOptional(parin,'polygon_in','');
addOptional(parin,'polygon_out','');
addOptional(parin,'polygon_in_bl','');
addOptional(parin,'ds',NaN);
addOptional(parin,'rkmi',NaN);
addOptional(parin,'rkmf',NaN);
addOptional(parin,'br','');
addOptional(parin,'fdir_out','');
addOptional(parin,'do_debug',0);
addOptional(parin,'mean','MEAN');
addOptional(parin,'count','COUNT');
addOptional(parin,'hm_code','hm_nummer');
addOptional(parin,'location','Locatie');
addOptional(parin,'surface','oppervlak_');
addOptional(parin,'location_sides',[-4:1:-1,1:1:4]); %L4-R4
addOptional(parin,'rkm_plot','');
addOptional(parin,'tol_fig',500);
addOptional(parin,'river_axis','');

parse(parin,varargin{:});

xlsx_range=parin.Results.xlsx_range;
etab_year=parin.Results.xlsx_range;
fpath_pol_in=parin.Results.polygon_in;
fpath_pol_out=parin.Results.polygon_out;
fpath_pol_in_bl=parin.Results.polygon_in_bl;
ds=parin.Results.ds;
rkmi=parin.Results.rkmi;
rkmf=parin.Results.rkmf;
br=parin.Results.br;
fdir_out=parin.Results.fdir_out;
do_debug=parin.Results.do_debug;
mean_str=parin.Results.mean;
count_str=parin.Results.count;
hm_code_str=parin.Results.hm_code;
location_str=parin.Results.location;
surface_str=parin.Results.surface;
location_sides=parin.Results.location_sides;
fpath_rkm=parin.Results.rkm_plot;
tol_fig=parin.Results.tol_fig;
fpath_ra=parin.Results.river_axis;

%%

do_pol_in=1;
if isempty(fpath_pol_in)
    do_pol_in=0;
end

do_pol_out=1;
if isempty(fpath_pol_out)
    do_pol_out=0;
end

do_rol_mean=1;
if isnan(ds)
    do_rol_mean=0;
end
%2DO: add that all data is available. Maybe better inside the right function.

[fdir,fname]=fileparts(fpath_data);
if isempty(fdir_out)
    fdir_out=fdir;
end

do_pol_in_bl=1;
if isempty(fpath_pol_in_bl)
    do_pol_in_bl=0;
end

do_plot=1;
if isempty(fpath_rkm)
    do_plot=0;
end

%% dia

fpath_dia=fullfile(fdir,sprintf('%s.log',fname));
fid_log=fopen(fpath_dia,'w');

%% read bed level

fpath_mat_tmp=fullfile(pwd,'rbl.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug
    messageOut(fid_log,'Start reading bed level');
    [etab_cen,pol]=load_etab(fpath_shp,fpath_data,xlsx_range,etab_year,mean_str,count_str);
    if do_debug
        save(fpath_mat_tmp,'etab_cen','pol')
    end
else
    messageOut(fid_log,'Start loading bed level');
    load(fpath_mat_tmp,'etab_cen','pol')
end

%% read grid

fpath_mat_tmp=fullfile(pwd,'rg.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug
    messageOut(fid_log,'Start reading grid');
    gridInfo=EHY_getGridInfo(fpath_grd,{'XYcen','XYcor','Zcen','Zcor','grid'}); %`Zcen` gives you `Zcor`
    if do_debug
        save(fpath_mat_tmp,'gridInfo')
    end
else
    messageOut(fid_log,'Start loading grid');
    load(fpath_mat_tmp,'gridInfo')
end

%% find centroids of polygons

fpath_mat_tmp=fullfile(pwd,'fc.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug
    messageOut(fid_log,'Start finding centroids');
    [xpol_cen,ypol_cen]=centroid_polygons(pol);
    if do_debug
        save(fpath_mat_tmp,'xpol_cen','ypol_cen')
    end
else
    messageOut(fid_log,'Start loading centroids');
    load(fpath_mat_tmp,'xpol_cen','ypol_cen')
end

%% BEGIN DEBUG

% load('data.mat')
% save('data.mat','pol','etab_cen','gridInfo','xpol_cen','ypol_cen')

% END DEBUG

%% roling mean

fpath_mat_tmp=fullfile(pwd,'rm.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug
    messageOut(fid_log,'Start computing rolling mean');
    if do_rol_mean
        etab_cen_mod=rolling_mean(fid_log,pol,ds,rkmi,rkmf,br,etab_cen,hm_code_str,location_str,surface_str,location_sides);
    else
        etab_cen_mod=etab_cen;
    end
    if do_debug
        save(fpath_mat_tmp,'etab_cen_mod')
    end
else
    messageOut(fid_log,'Start loading rolling mean');
    load(fpath_mat_tmp,'etab_cen_mod')
end

%% read polygons of points to include

fpath_mat_tmp=fullfile(pwd,'polin.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug 
    bol_in=true(numel(gridInfo.Xcen),1);
    if do_pol_in
        messageOut(fid_log,'Start finding points in polygon')    
        bol_in=points_in_shp_and_grid(fpath_pol_in,gridInfo.Xcen,gridInfo.Ycen);
    else
        messageOut(fid_log,'Skip finding points in polygon')
    end
    if do_debug
        save(fpath_mat_tmp,'bol_in')
    end
else
    messageOut(fid_log,'Start loading points in polygon')   
    load(fpath_mat_tmp,'bol_in')
end

%% read polygons of points to exclude

fpath_mat_tmp=fullfile(pwd,'polout.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug 
    bol_out=false(numel(gridInfo.Xcen),1);
    if do_pol_out
        messageOut(fid_log,'Start finding points out polygon')
        bol_out=points_in_shp_and_grid(fpath_pol_out,gridInfo.Xcen,gridInfo.Ycen);
    else
        messageOut(fid_log,'Skip finding points out polygon')
    end
    if do_debug
        save(fpath_mat_tmp,'bol_out')
    end
else
    messageOut(fid_log,'Start loading points out polygon')   
    load(fpath_mat_tmp,'bol_out')
end

%% read polygons of point to include in interpolation of bed level polygon

fpath_mat_tmp=fullfile(pwd,'polin_pol.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug 
    bol_in_pol=true(numel(xpol_cen),1);
    if do_pol_in_bl
        messageOut(fid_log,'Start finding points in polygon (bed level)')    
        bol_in_pol=points_in_shp_and_grid(fpath_pol_in_bl,xpol_cen,ypol_cen);
    else
        messageOut(fid_log,'Skip finding points in polygon (bed level)')
    end
    if do_debug
        save(fpath_mat_tmp,'bol_in_pol')
    end
else
    messageOut(fid_log,'Start loading points in polygon (bed level)')   
    load(fpath_mat_tmp,'bol_in_pol')
end

%% BEGIN DEBUG

% bol_out_aux=load('p:\11209261-rivierkunde-2023-morerijn\05_data\230321_bed_level\04_pol_out\bol.mat');
% bol_in_aux=load('p:\11209261-rivierkunde-2023-morerijn\05_data\230321_bed_level\03_pol_in\bol.mat');
% 
% % pol_xy=polcell2nan(pol.xy.XY);
% % shp=D3D_io_input('read','p:\11209261-rivierkunde-2023-morerijn\05_data\230321_bed_level\07_pol_in_bl\waal.shp','xy_only',1);
% %
% % tfile=readmatrix("c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\230321_rijntakken_mor\test.xyz",'FileType','text'); 
% 
% figure
% hold on
% % plot(pol_xy(:,1),pol_xy(:,2),'k')
% % plot(gridInfo.grid(:,1),gridInfo.grid(:,2),'r')
% plot(bol_in_aux.x_pol_in,bol_in_aux.y_pol_in,'g')
% plot(bol_out_aux.x_pol_in,bol_out_aux.y_pol_in,'r')
% % scatter(xint,yint,10,'xk');
% % scatter(xint,yint,10,etab_cengrd_mod);
% scatter(xint(bol_nn),yint(bol_nn),10,'b');
% % scatter(tfile(:,1),tfile(:,2),10,tfile(:,3))
% % scatter(gridInfo.Xcor,gridInfo.Ycor,10,gridInfo.Zcor,'filled')
% % scatter(xpol_cen,ypol_cen,10,etab_cen,'s','filled')
% % scatter(xpol_cen(bol_cen_int),ypol_cen(bol_cen_int),10,etab_cen_mod(bol_cen_int),'x','filled')
% % plot(shp(:,1),shp(:,2))
% % scatter(xpol_cen,ypol_cen,20,etab_cen_mod,'s','filled')
% % scatter(xint,yint,10,zint,'filled')
% colorbar
% axis equal
% % 
% % % END DEBUG

%% convert to s-n domain

x_grd_cen=gridInfo.Xcen;
y_grd_cen=gridInfo.Ycen;

fpath_mat_tmp=fullfile(pwd,'sn.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug 
    [s_pol_cen,n_pol_cen]=convert_to_sn(fpath_ra,xpol_cen,ypol_cen);
    [s_grd_cen,n_grd_cen]=convert_to_sn(fpath_ra,x_grd_cen,y_grd_cen);
    if do_debug
        save(fpath_mat_tmp,'s_pol_cen','n_pol_cen','s_grd_cen','n_grd_cen')
    end
else
    messageOut(fid_log,'Start loading s-n coordinates')   
    load(fpath_mat_tmp,'s_pol_cen','n_pol_cen','s_grd_cen','n_grd_cen')
end

%% interpolate polygon bed level at grid centres 

bol_n=isnan(etab_cen_mod);
bol_cen_int=~bol_n & bol_in_pol;

F_fil=scatteredInterpolant(s_pol_cen(bol_cen_int),n_pol_cen(bol_cen_int),etab_cen_mod(bol_cen_int),'linear','none'); %filtered

bol_n=isnan(etab_cen);
bol_cen_int=~bol_n & bol_in_pol;

F_ori=scatteredInterpolant(s_pol_cen(bol_cen_int),n_pol_cen(bol_cen_int),etab_cen(bol_cen_int),'linear','none'); %original

bol_grd_int=bol_in & ~bol_out;

etab_cengrd_mod=F_fil(s_grd_cen(bol_grd_int),n_grd_cen(bol_grd_int));
etab_cengrd_ori=F_ori(s_grd_cen(bol_grd_int),n_grd_cen(bol_grd_int));

%% write

if 0
messageOut(fid_log,'Start writing')  
mkdir_check(fdir_out);

%1) bed level from polygons

    %1.1) original on polygon centres
bol_nn=~isnan(etab_cen);
fpath_xyz=fullfile(fdir_out,sprintf('etab_pol_cenpol_original_%s.xyz',now_chr));
D3D_io_input('write',fpath_xyz,[xpol_cen(bol_nn),ypol_cen(bol_nn),etab_cen(bol_nn)]);

    %1.2) filtered on polygon centres
bol_nn=~isnan(etab_cen_mod);
fpath_xyz=fullfile(fdir_out,sprintf('etab_pol_cenpol_filtered_%s.xyz',now_chr));
D3D_io_input('write',fpath_xyz,[xpol_cen(bol_nn),ypol_cen(bol_nn),etab_cen_mod(bol_nn)]);

    %1.3) filtered on grid centres 
bol_nn=~isnan(etab_cengrd_mod);
fpath_xyz=fullfile(fdir_out,sprintf('etab_pol_cengrd_filtered_%s.xyz',now_chr));
D3D_io_input('write',fpath_xyz,[x_grd_cen(bol_nn),y_grd_cen(bol_nn),etab_cengrd_mod(bol_nn)]);

    %1.4) original on grid centres 
bol_nn=~isnan(etab_cengrd_ori);
fpath_xyz=fullfile(fdir_out,sprintf('etab_pol_cengrd_original_%s.xyz',now_chr));
D3D_io_input('write',fpath_xyz,[x_grd_cen(bol_nn),y_grd_cen(bol_nn),etab_cengrd_ori(bol_nn)]);

%2) bed level from grid

    %2.1) original on grid corners
bol_nn=~isnan(gridInfo.Zcor);
fpath_xyz=fullfile(fdir_out,sprintf('etab_grd_corgrd_original_%s.xyz',now_chr));
D3D_io_input('write',fpath_xyz,[gridInfo.Xcor(bol_nn),gridInfo.Ycor(bol_nn),gridInfo.Zcor(bol_nn)]);

    %2.3) original on grid centres
bol_nn=~isnan(gridInfo.Zcen);
fpath_xyz=fullfile(fdir_out,sprintf('etab_grd_cengrd_original_%s.xyz',now_chr));
D3D_io_input('write',fpath_xyz,[gridInfo.Xcen(bol_nn),gridInfo.Ycen(bol_nn),gridInfo.Zcen(bol_nn)]);

end

%% PLOT

if do_plot
    messageOut(fid_log,'Start plotting')  
    plot_interpolate_bed_level(fdir_out,gridInfo,pol,xpol_cen,ypol_cen,etab_cen,etab_cen_mod,x_grd_cen(bol_grd_int),y_grd_cen(bol_grd_int),etab_cengrd_mod,fpath_rkm,tol_fig)
else
    messageOut(fid_log,'Skip plotting')  
end

%%

fclose(fid_log);

end %main function

%%
%% FUNCTIONS
%%

%% load_etab

function [etab_cen,pol]=load_etab(fpath_shp,fpath_data,xlsx_range,etab_year,mean_str,count_str)

[~,~,ext]=fileparts(fpath_data);
switch ext
    case '.xlsx'
        messageOut(fid_log,'Start reading Excel bed level');
        etab_pol_y=load_etab_excel(fpath_xlsx,xlsx_range,etab_year);
        
        messageOut(fid_log,'Start reading shp');
        pol=D3D_io_input('read',fpath_shp,'read_val',1);

        messageOut(fid_log,'Start matching polygon with Excel');
        etab_cen=match_pol_Excel(etab_pol_y,pol);

    case '.dbf'
        [etab_cen,pol]=load_etab_dbf(fpath_shp,fpath_data,mean_str,count_str);
        
    otherwise
        error('Unrecognized extension of data file: %s',ext)
end %ext

end %function


%% load_etab_excel

function data_year=load_etab_excel(fpath_xlsx,xlsx_range,etab_year)
    
[fdir,fname]=fileparts(fpath_xlsx);
fpath_mat=fullfile(fdir,sprintf('%s.mat',fname));
if exist(fpath_mat,'file')~=2
    transform2mat(fpath_xlsx,fpath_mat,xlsx_range,etab_year)
end
load(fpath_mat,'data');
    
%% year

bol_year=[data.year]==etab_year;
data_year=data(bol_year);

end %function

%%

%Adapted from that by WO
%
function transform2mat(fpath_xlsx,fpath_mat,xlsx_range)

%%

if isempty(xlsx_range)
    messageOut(fid_log,'Start reading all Excel');
    M=readcell(fpath_xlsx);
else
    %There are problem when reading without limits. Also, specifying the limits is not a perfect solution
    %first and last cells change. Not nice. 
    messageOut(fid_log,sprintf('Start reading Excel range %s',xlsx_range));
    M=readcell(fpath_xlsx,'Range',xlsx_range);
end

row_year=1; %careful. WHen reading the the actual first row may change

%%
messageOut(fid_log,'Start processing Excel');

row_varname=row_year+2;
row_data1=row_varname+1;
[N1,N2]=size(M);
kyear=0;
for k = 1:N2
    year_d=M{row_year,k};
    if ~ismissing(year_d)
        kyear=kyear+1;
        if ~isa(year_d,'double')
            messageOut(fid_log,sprintf('WARNING: It should be a year (double) but it is not, I am skipping: %s',year_d));
            continue
        end
        data(kyear).year=year_d;
        for j = 0:5
            varname_c=M{row_varname,k+j};
            varname = matlab.lang.makeValidName(varname_c);
            data3 = NaN*ones(N1-3,1);
            for m = row_data1:N1
                var_c=M{m,k+j};
                switch(varname)
                    case 'code'
                        if ismissing(var_c)
                            continue
                        end
                        val=pol_str2double(var_c);
                        data3(m-3) = val;
                        data(kyear).(varname) = data3;
                    case 'letter'
                        data(kyear).(varname)(m-3)=letter2double(var_c);
                    otherwise
                        if (~any(ismissing(var_c)) && ~ischar(var_c))
                            data3(m-3)=var_c;
                        end
                        data(kyear).(varname)=data3;
                end
            end %m
        end %j
        
        %Here we rely on the name of the variable in the file.
        fn=fieldnames(data(kyear));
        str_find_c={'MEAN','STD','COUNT','uniek'};
        idx_fn=find_str_in_cell(fn,str_find_c);
        if numel(idx_fn)~=numel(str_find_c)
            error('I expect to have read variables %s',conccellstr(str_find_c))
        end
        bol_nd=data(kyear).COUNT==0;
        data(kyear).MEAN(bol_nd)=NaN;
        data(kyear).STD(bol_nd)=NaN;
        data(kyear).COUNT(bol_nd)=NaN;
        
        data(kyear).MEAN=data(kyear).MEAN/100;
        data(kyear).STD=data(kyear).STD/100;
        data(kyear).uniek=data(kyear).uniek/1000;
        
        messageOut(fid_log,sprintf('Processed year %d',data(kyear).year));
    end %missing
end %k

%% SAVE

save_check(fpath_mat,'data'); 

end %function

%%

function ld=letter2double(var_c)

ld=NaN;
if isempty(var_c)
    return
elseif strcmp(var_c(1),'N')
    ld=1;
elseif strcmp(var_c(1),'Z')
    ld=2;
end

                        
end %function

%%

function etab_cen=match_pol_Excel(etab_pol_y,pol)
        
%% get polygon names

str_pol={'polygon:hm_punt','polygon:locatie','polygon:Z_N'}; 
polnames=cellfun(@(X)X.Name,pol.val,'UniformOutput',false);
idx_pol=find_str_in_cell(polnames,str_pol);
if numel(idx_pol)~=3
    error('I cannot find one of the strings')
end
pol_hm=pol.val{idx_pol(1)}.Val;
pol_lo_str=pol.val{idx_pol(2)}.Val;
pol_lo_num=cellfun(@(X)pol_str2double(X),pol_lo_str);
pol_let_str=pol.val{idx_pol(3)}.Val;
pol_let_num=cellfun(@(X)letter2double(X),pol_let_str);

%% bed level at each polygon

npol=numel(pol.xy.XY);
etab_cen=NaN(npol,1);
for kpol=1:npol
    bol_hm=pol_hm(kpol)==etab_pol_y.uniek;
    bol_lo=pol_lo_num(kpol)==etab_pol_y.code;
    bol_get=bol_lo&bol_hm;
    if sum(bol_get)>1
        if isnan(pol_let_num(kpol))
            bol_let=isnan(etab_pol_y.letter)';
        else
            bol_let=pol_let_num(kpol)==etab_pol_y.letter';
        end
        bol_get=bol_get&bol_let;
    end
    if sum(bol_get)~=1
        error('Not 1 polygon with the same info')
    end
    etab_cen(kpol)=etab_pol_y.MEAN(bol_get);
    fprintf('Bed level in polygon %4.2f %% \n',kpol/npol*100);
end %kpol
        
end %function

%%

function [ident_pol_str,rkm_pol_num,br_pol_num,loc_pol_num,area_cen]=data_pol(pol,hm_code_str,location_str,surface_str)

str_pol={sprintf('polygon:%s',hm_code_str),sprintf('polygon:%s',location_str),sprintf('polygon:%s',surface_str)}; 
polnames=cellfun(@(X)X.Name,pol.val,'UniformOutput',false);
idx_pol=find_str_in_cell(polnames,str_pol);
if any(isnan(idx_pol)) || numel(str_pol)~=numel(idx_pol)
    fprintf('\n')
    fprintf('Names in polygon:\n')
    nn=numel(polnames);
    for kn=1:nn
        fprintf('%s \n',polnames{kn})
    end
    fprintf('\n');
    fprintf('Names trying to find in polygon (pair input to the function):\n')
    fprintf('hm_code  = %s\n',hm_code_str)
    fprintf('location = %s\n',location_str)
    fprintf('surface  = %s\n',surface_str)

    error('Could not find variable in shapefile. Maybe the variable name is different. Check above.');
end

%rkm, br
ident_pol_str=pol.val{idx_pol(1)}.Val;
if iscell(ident_pol_str)
    [rkm_pol_num,br_pol_num]=rkm_br_from_polygon_cell(ident_pol_str);
else 
    error('A cell array is expected with information on branch and river kilometer for polygon flag %s',hm_code_str)
end

%location
loc_str=pol.val{idx_pol(2)}.Val;
loc_pol_num=cellfun(@(X)pol_str2double(X),loc_str);

%area
area_cen=pol.val{idx_pol(3)}.Val;

end %function

%%

function etab_cen_mod=rolling_mean(fid_log,pol,ds,rkmi,rkmf,br,etab_cen,hm_code_str,location_str,surface_str,location_sides)

[ident_pol_str,rkm_pol_num,br_pol_num,loc_pol_num,area_cen]=data_pol(pol,hm_code_str,location_str,surface_str);

etab_cen_mod=NaN(size(etab_cen));
pol_d=polygon_ds(br);
rkm_q_v=rkmi:pol_d/1000:rkmf; %vector of query rkm. A vector of points to assess irrespective of polygons. Make sure it is smaller than the polygons. 
nrkm=numel(rkm_q_v);
nl=numel(location_sides);
tol_rkm=1e-10;
for krkm=1:nrkm
    rkm_q=rkm_q_v(krkm); %query rkm (any) at which to compute the mean
    rkm_q=correct_for_bendcutoff(rkm_q,rkm_q-0.1,br); %the substract makes that we are looking towards downstream, as expected from creating `rkm_q_v`
    rkm_mod=rkm_of_pol(rkm_q,br); %rkm to modify. Along a certain branch closest to the query rkm. 
    [br_mod_str,br_mod_num]=branch_str_num(rkm_mod,br,'ni_bo',true); %branch name to modify (e.g., BO) for a given rkm and river branch (e.g. WA). 
    [rkm_me,br_me]=get_pol_along_line(rkm_q,br_mod_str{1},ds); %rkm and branch to compute the mean
    
    bol_rkm_me=ismember_num(rkm_pol_num,rkm_me,tol_rkm); %boolean of the rkm to compute the mean
    bol_br_me=ismember(br_pol_num,br_me); %boolean of the branch to compute the mean
    bol_rkm_mod=rkm_pol_num>rkm_mod-tol_rkm & rkm_pol_num<rkm_mod+tol_rkm; %boolean rkm to modify
    bol_br_mod=ismember(br_pol_num,br_mod_num); %boolean branch to modify
    
    for kl=1:nl
        bol_loc=location_sides(kl)==loc_pol_num;
        bol_me =bol_rkm_me  & bol_loc & bol_br_me ;
        bol_mod=bol_rkm_mod & bol_loc & bol_br_mod;

        str_mod=ident_pol_str(bol_mod);
        str_me =ident_pol_str(bol_me);

        if sum(bol_mod)==0
            messageOut(fid_log,sprintf('There is no polygon to modify at rkm %f branch %s',rkm_mod,br_mod_str{1}));
            error('ups')
        elseif sum(bol_mod)~=1
            messageOut(fid_log,sprintf('Duplicate polygons: %s',str_mod{1}))
        end
        num_pol_min=5;
        if sum(bol_me)<num_pol_min
            messageOut(fid_log,sprintf('There less %d polygons (less than threshold %d) to average %s (%s).',sum(bol_me),num_pol_min,str_mod{1},conccellstr(str_me)))
            error('ups')
        end

        etab_cen_mod(bol_mod)=sum(etab_cen(bol_me).*area_cen(bol_me))/sum(area_cen(bol_me));
        
        %disp (expensive but useful)
        fprintf(fid_log,'Location %2d, %s :      %s \n',location_sides(kl),conccellstr(str_mod),conccellstr(str_me));
        
        %DEBUG
%         ident_pol_str(bol_me)
%         ident_pol_str(bol_mod)
%         sum(bol_rkm_me&bol_br_me)
%         unique(ident_pol_str(bol_rkm_me&bol_br_me))
%         unique(ident_pol_str(bol_rkm_me))
        %END DEBUG
        
    end %kl
    fprintf('Rolling mean %4.2f %% \n',krkm/nrkm*100)
end %krkm

end %function

%%

function [rkm_pol_num,br_pol_num]=rkm_br_from_polygon_cell(ident_pol_str)

%check that data is available
ise=cellfun(@(X)isempty(X),ident_pol_str);
if any(ise)
    error('There is empty data in the polygon. For instance, an entry with no value for the polygon name (e.g., `hm_nummer`).')
end

ise=cellfun(@(X)numel(X)<2,ident_pol_str);
if any(ise)
    error('The size of the string identifying each polygon is too short. It is expected that the first two characters identify the branch (e.g., `IJ_881.90`).')
end

ise=cellfun(@(X)numel(X)<4,ident_pol_str);
if any(ise)
    error('The size of the string identifying each polygon is too short. It is expected that the characters starting from the 4th identify the river kilometer (e.g., `IJ_881.90`).')
end

ise=cellfun(@(X)numel(X)<9,ident_pol_str);
if any(ise)
    warning('The size of the string identifying each polygon may be too short. It is expected that the characters starting from the 4th identify the river kilometer (e.g., `IJ_881.90`).')
end

%process
rkm_pol_num=cellfun(@(X)str2double(X(4:end)),ident_pol_str);

switch which_river(ident_pol_str)
    case 1
        messageOut(NaN,'Rijntakken branches identified.')
        br_pol_num=cellfun(@(X)branch_rijntakken_str2double(X(1:2)),ident_pol_str);
    case 2
        messageOut(NaN,'Maas branches identified.')
        br_pol_num=cellfun(@(X)branch_maas_str2double(X(1:2)),ident_pol_str);
    otherwise
        %error is deal in `which_river`.
end

end %function

%%

function plot_interpolate_bed_level(fdir_out,gridInfo,pol,xpol_cen,ypol_cen,etab_cen,etab_cen_mod,xint,yint,etab_cengrd_mod,fpath_rkm,tol)

pol_xy=polcell2nan(pol.xy.XY);
in_p=v2struct(gridInfo,xpol_cen,ypol_cen,etab_cen,etab_cen_mod,xint,yint,etab_cengrd_mod,pol_xy);

fdir_fig=fullfile(fdir_out,'figures');
mkdir_check(fdir_fig);

rkm=readcell(fpath_rkm);

nrkm=size(rkm,1)-1; %first is header
for krkm=1:nrkm
    in_p.lims_x=[rkm{krkm+1,1}-tol,rkm{krkm+1,1}+tol];
    in_p.lims_y=[rkm{krkm+1,2}-tol,rkm{krkm+1,2}+tol];
    in_p.fname=fullfile(fdir_fig,sprintf('%s',rkm{krkm+1,3}));

    fig_interpolate_bed_level(in_p)
end

end %function

%%

function [s,n]=convert_to_sn(fpath_ra,x,y)

%% PARSE

if isempty(fpath_ra)
    messageOut(NaN,'Not converting to s-n coordinates.')
    s=x;
    n=y;
    return
end
messageOut(NaN,'Converting to s-n coordinates.')

if ~isfile(fpath_ra)
    error('No file with river axis coordinates: %s',fpath_ra)
end

%% CALC

T=readtable(fpath_ra);
[s,n]=xy_to_sn(T.X,T.Y,x,y);

end %function














