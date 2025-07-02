%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20182 $
%$Date: 2025-06-02 17:47:54 +0200 (Mon, 02 Jun 2025) $
%$Author: chavarri $
%$Id: D3D_io_input.m 20182 2025-06-02 15:47:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_io_input.m $
%
%Plot meteorological condition. 
%
%INPUT:
%   -
%
%E.G.
%
% in_p.data_mag=data_mag;
% in_p.data_dir=data_dir;
% in_p.data_tim=data_tim;
% in_p.data_varname=data_varname;
% in_p.fdir_out='p:\11209117-021-ipdc-col-large-scale\05_data\05_ERA5\03\';
% 
% plot_meteo(in_p)
%
%E.G. 
% in_p.data_mag_x=data_u10.waarde;
% in_p.data_mag_y=data_v10.waarde;
% in_p.data_tim=data_u10.time;
% in_p.data_varname='wind_mag';
% in_p.fdir_out='p:\11209117-021-ipdc-col-large-scale\05_data\05_ERA5\04\wind';
% 
% plot_meteo(in_p)


function plot_meteo(in_p)

%% PARSE

in_p=isfield_default(in_p,'fdir_out',pwd);
in_p=isfield_default(in_p,'lan','en');
in_p=isfield_default(in_p,'fig_overwrite',1);
in_p=isfield_default(in_p,'data_mag',[]);
in_p=isfield_default(in_p,'data_mag_x',[]);
in_p=isfield_default(in_p,'data_mag_y',[]);
in_p=isfield_default(in_p,'data_dir',[]);

v2struct(in_p)

%% CALC

mkdir_check(fdir_out);

%% convert x-y to direction and magnitude

if isempty(data_mag) 
    %magnitude is not provided, then we have magnitude in x and y
    if isempty(data_mag_x) || isempty(data_mag_y)
        error('Magnitude is not provided. Provide magnitude in x and y direction.')
    end
    if ~isempty(data_dir)
        error('Magnitude in x and y is provided. Direction cannot be given.')
    end
    data_mag=hypot(data_mag_x,data_mag_y);
    data_dir=xy2north_deg(data_mag_x,data_mag_y);
else
    %magnitude is provided, then we do not have magnitude in x and y
    if ~isempty(data_mag_x) || ~isempty(data_mag_y)
        error('Magnitude is provided. Do not provide magnitude in x and y direction.')
    end
    if isempty(data_dir)
        error('Magnitude is provided. Direction must be given.')
    end
    [data_mag_x,data_mag_y]=degN2xy(data_dir,data_mag);
end

%% wind rose

%To do: move plotting of windrose to function to be able to control it. 
[lab,str_var,str_un,str_diff,str_background,str_std,str_diff_back,str_fil,str_rel,str_perc,str_dom]=labels4all(data_varname,1,lan);
figure
wind_rose(data_dir,data_mag,'dtype','meteo','units',str_un);
fpath_out=fullfile(fdir_out,'rose.png');
printV(gcf,fpath_out);

%% magnitude and direction

plot_variables={'dir','mag'};

np=numel(plot_variables);

for kp=1:np
    plot_variable=plot_variables{kp};
    switch plot_variable
        case 'mag'
            in_p.val=data_mag;
            in_p.varname=data_varname;
            in_p.title_str='';
            in_p.do_title=0;
        case 'dir'
            in_p.val=data_dir;
            in_p.varname='dir';
            in_p.title_str=str_var;
            in_p.do_title=1;
    end

    %% time series

    in_p.s=data_tim;
    in_p.fname=fullfile(fdir_out,plot_variable);

    fig_1D_01(in_p);

    %% hist

    in_p.normalization='count';
    in_p.fname=fullfile(fdir_out,sprintf('%s_hist_count',plot_variable));
    
    fig_histogram(in_p)
    
    in_p.normalization='pdf';
    in_p.fname=fullfile(fdir_out,sprintf('%s_hist_pdf',plot_variable));
    
    fig_histogram(in_p)
    
    in_p.normalization='probability';
    in_p.fname=fullfile(fdir_out,sprintf('%s_hist_prob',plot_variable));
    
    fig_histogram(in_p)
end %kp

%% x-y plot

in_p.x=data_mag_x;
in_p.y=data_mag_y;
in_p.do_axis_equal=true;

in_p.fname=fullfile(fdir_out,sprintf('%s_count','xy'));
in_p.normalization='count';
fig_imagesc(in_p);

in_p.fname=fullfile(fdir_out,sprintf('%s_perc','xy'));
in_p.normalization='percentage';
fig_imagesc(in_p);

end %function
