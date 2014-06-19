function Plot_S_phi(input)
%plotS_phi.m : Plots S-phi output
%
%   Syntax:
%     function Plot_S_phi(input)
% 
%   Input:
%     input     structure with information on the S-Phi curves and plotting formats
%                    .dir         directory with files
%                    .file        RAY-file or GLO-file
%                    .reffile     reference RAY-file or GLO-file
%                    .test_id     run name (used for name of plotted graph)
%                    .fignum      figure number
%                    .output_dir  output directory for plots
%  
%   Output:
%     graph with S-Phi curves
%
%   Example:
%     input.dir=pwd;
%     input.file='file1.RAY';
%     input.reffile='file2.RAY';
%     input.test_id='DEF';
%     input.fignum=1;
%     input.output_dir='';
%     Plot_S_phi(input);
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: Plot_S_phi.m 3493 2013-02-06 13:44:44Z huism_b $
% $Date: 2013-02-06 14:44:44 +0100 (Wed, 06 Feb 2013) $
% $Author: huism_b $
% $Revision: 3493 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/postprocess/Plot_S_phi.m $
% $Keywords: $

%INPUT
color = [{'b'},{'r'}];
markers1 = {'.','none'};
markers2 = {'x','+'};
file  = {input.file,input.reffile};
addpath(genpath(input.dir));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% READ DATA                                  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ii = 1:length(file)
    if strcmpi(file{ii}(end-3:end),'.ray')
        data(ii) = readRAY([file{ii}(1:end-4) '.RAY']);
    elseif strcmpi(file{ii}(end-3:end),'.glo')
        data(ii) = readGLO([file{ii}(1:end-4) '.GLO']);
    end
    for jj=1:length(data(ii).equi)
        D(ii).equi(jj)        = data(ii).equi(jj);
        D(ii).c1(jj)          = data(ii).c1(jj);
        D(ii).c2(jj)          = data(ii).c2(jj);
        D(ii).Cangle(jj)      = data(ii).hoek(jj);
        D(ii).QSoffset(jj)    = data(ii).QSoffset(jj);

        D(ii).phi_e(jj)       = D(ii).Cangle(jj)-D(ii).equi(jj);
        D(ii).Cequi(jj)       = data(ii).Cequi(jj);
        if strcmpi(file{ii}(end-3:end),'.glo')
            D(ii).rota{jj}        = data(ii).rota;
            D(ii).QScalc{jj}      = data(ii).QScalc;
        end
        D(ii).phi{jj}         = [D(ii).phi_e(jj)-70:0.1:D(ii).phi_e(jj)+70];
        D(ii).phi_r{jj}       = D(ii).phi{jj}-D(ii).phi_e(jj);

        %Process data
        D(ii).Qs{jj}          = -D(ii).c1(jj).*D(ii).phi_r{jj}.*exp(-((D(ii).c2(jj).*D(ii).phi_r{jj}).^2)) +D(ii).QSoffset(jj)/1000;

        %Transport at current angle
        D(ii).Qc{jj}          = -D(ii).c1(jj).*(D(ii).Cangle(jj)-D(ii).phi_e(jj)).*exp(-(D(ii).c2(jj).*(D(ii).Cangle(jj)-D(ii).phi_e(jj))).^2) +D(ii).QSoffset(jj)/1000;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOT DATA                                  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for jj=1:length(data(ii).equi)
    f = figure();set(gcf,'Position',[207 208 868 450]);set(gcf,'Color',[1 1 1]);hold off;
    set(gcf,'PaperSize',[29.6774 10.492],'PaperPosition',[0 0 29.6774 10.492],'PaperUnits','centimeters','PaperType','A4','PaperPositionMode','manual');
    for ii = 1:length(file)
        hline(ii)   = plot(D(ii).phi{jj},D(ii).Qs{jj}*1000,'LineStyle','-','Marker',markers1{ii},'Color',color{ii});hold on;
        if strcmpi(file{ii}(end-3:end),'.glo')
            plot(D(ii).Cangle(jj)-D(ii).rota{jj},D(ii).QScalc{jj}*1000,'LineStyle','none','Marker',markers2{ii},'Color',color{ii});hold on;
        end
        xl = xlim; yl = ylim;
    end
    ii=1;plot([D(ii).Cangle(jj) D(ii).Cangle(jj)],[yl(1) yl(2)],'Color','k','LineStyle',':','Marker','None');
    for ii = 1:length(file)
        %% Plot equilibrium line
        plot([D(ii).Cequi(jj) D(ii).Cequi(jj)],[yl(1) yl(2)],'Color',color{ii},'LineStyle','--','Marker','None');
    end
    if yl(1)<=0 && yl(2)>=0
        plot([xl(1) xl(2)],[0 0],'k');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FORMAT PLOT                                %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(gca,'FontSize',8);
    xlabel('Coast angle (phi [°])');
    ylabel('Total transport (Qs [10^3 m^3/yr])');
    annotation('textbox',[0.15 0.86 0.30 0.05],'String',strcat('File=',file{1}),'interpreter','none','FontSize',8,'Edgecolor','none','FontAngle','italic'); %,'Backgroundcolor',[1 1 0.9]'Backgroundcolor',[1 1 0.5]
    annotation('textbox',[0.15 0.82 0.30 0.05],'String',strcat('Coastangle [°N]  = ',num2str(round(D(1).Cangle(jj)*10)/10)),'FontSize',8,'Edgecolor','none');
    annotation('textbox',[0.15 0.78 0.30 0.05],'String',strcat('Eq. angle [°N] = ',num2str(round(mod(D(1).Cequi(jj),360)*10)/10),' (ref: ',num2str(round(mod(D(2).Cequi(jj),360)*10)/10),')'),'FontSize',8,'Edgecolor','none');
    annotation('textbox',[0.15 0.74 0.30 0.05],'String',strcat('Qcoast [10^3 m^3/y] = ',num2str(round(D(1).Qc{jj}*1000*10)/10),' (ref: ',num2str(round(D(2).Qc{jj}*1000*10)/10),')'),'FontSize',8,'Edgecolor','none');
    if strcmpi(file{ii}(end-3:end),'.glo')
      legtext = {[file{1} '_approximated'],[file{1} '_calculated'],['Reference_approximated'],['Reference_calculated'],'current coastline'};
    else
      legtext = {[file{1} '_approximated'],[file{1} '_calculated'],'current coastline'};
    end
    legend(legtext,'interpreter','none','location','SouthEast');
    set(gca,'Xticklabel',num2str(mod(str2num(get(gca,'Xticklabel')),360)));
    set(gca,'FontSize',8);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAVE DATA                                  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if length(data(ii).equi)==1
        %outputname for normal GLO/RAY
        pname = [input.test_id '_fig' num2str(input.fignum)];
    else
        %outputname for timeseries
        pname = [input.test_id '_fig' num2str(input.fignum),'_',num2str(jj,'%03.0f')];
    end
    saveplot(f, input.output_dir, pname);
    close all;
end