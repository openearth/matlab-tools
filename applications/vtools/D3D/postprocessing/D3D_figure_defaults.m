%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_figure_2D.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_figure_2D.m $
%
%plot of 1D volume fraction 2

function flg=D3D_figure_defaults(flg)

if isfield(flg,'prnt_size')==0
    flg.prnt_size=[0,0,25.4,19.05];
end

if isfield(flg.prop,'edgecolor')==0
    flg.prop.edgecolor='k'; %edge color in surf plot
end

if isfield(flg,'cbar')==0
        flg.cbar.displacement=[0,0,0,0];
else
    if isfield(flg.cbar,'displacement')==0
        
    end
end

if isfield(flg,'marg')==0
    flg.marg.mt=2.5; %top margin [cm]
    flg.marg.mb=1.5; %bottom margin [cm]
    flg.marg.mr=2.5; %right margin [cm]
    flg.marg.ml=2.0; %left margin [cm]
    flg.marg.sh=1.0; %horizontal spacing [cm]
    flg.marg.sv=0.0; %vertical spacing [cm]
end

if isfield(flg.prop,'fs')==0
    flg.prop.fs=12;
end

if isfield(flg,'addtitle')==0
    flg.addtitle=1;
end

if isfield(flg,'language')==0
    flg.language='en';
end

if isfield(flg,'fig_visible')==0
    if flg.print>=1
        flg.fig_visible=0;
    else
        flg.fig_visible=1;
    end
end %function