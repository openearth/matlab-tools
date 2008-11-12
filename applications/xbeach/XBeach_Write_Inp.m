function XB = XBeach_Write_Inp(calcdir, XB)
% XBEACH_WRITE_INP writes input file for xbeach calculation
%
% Routine writes an input file params.txt containing the information
% available in the XBeach communication structure XB.
%
% Input:
% calcdir = target directory to put the input file in
% XB      = XBeach communication structure
%
% Output:
% XB      = XBeach communication structure (contains the information as it
% is actually written to the inputfile (is relevant when values are rounded
% in the inputfile)
%
% See also CreateEmptyXBeachVar XBeach_Write_Inp XB_Read_Results

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Pieter van Geer
%
%       Pieter.vanGeer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id$ 
% $Date$
% $Author$
% $Revision$

%% make grid and dep file
xgrid = (0:1:XB.settings.Grid.nx)*XB.settings.Grid.dx+XB.settings.Grid.xori;
ygrid = (0:1:XB.settings.Grid.ny)*XB.settings.Grid.dy+XB.settings.Grid.yori;

% Initial bottom (specific for delta flume)
if max(xgrid)>max(XB.Input.xInitial)
    XB.Input.xInitial = [XB.Input.xInitial;max(xgrid)];
    XB.Input.zInitial = [XB.Input.zInitial;XB.Input.zInitial(end)];
end
if min(xgrid)<min(XB.Input.xInitial)
    XB.Input.xInitial = [min(xgrid); XB.Input.xInitial];
    XB.Input.zInitial = [XB.Input.zInitial(1);XB.Input.zInitial];
end

z = interp1(XB.Input.xInitial,XB.Input.zInitial,xgrid);
% write dep file
XB.settings.Info.initialzs0 = XB.settings.Flow.zs0;
if isempty(XB.settings.Flow.zs0)
    zs0=0;
else
    zs0=XB.settings.Flow.zs0;
    XB.settings.Flow.zs0=0;
    if length(zs0)>1
        % time series
        zs0(:,1)=zs0(:,1)*3600/XB.settings.SedInput.morfac;
        dlmwrite([calcdir filesep 'waterlevels.wls'],zs0,'delimiter','\t','Precision','%5.3f');
        XB.settings.Flow.zs0file = 'waterlevels.wls';
        XB.settings.Flow.tidelen = size(zs0,1);
        XB.settings.Flow.tideloc = size(zs0,2)-1;
        zs0 = 0;
    end
end
dlmwrite([calcdir filesep XB.settings.Grid.depfile],repmat(z-zs0,length(ygrid),1),'delimiter','\t','Precision','%5.3f');

%% make wave boundary file
if ~isempty(XB.settings.Waves.Hrms) && ~isempty(XB.settings.Waves.Tm01)
    if length(XB.settings.Waves.Hrms)==1
        XB.settings.Waves.Hrms = [XB.settings.Flow.tstop XB.settings.Waves.Hrms];
    else
        XB.settings.Waves.Hrms(:,1) = XB.settings.Waves.Hrms(:,1)*3600/XB.settings.SedInput.morfac;
    end
    if length(XB.settings.Waves.Tm01)==1
        XB.settings.Waves.Tm01 = [XB.settings.Flow.tstop XB.settings.Waves.Tm01];
    else
        XB.settings.Waves.Tm01(:,1) = XB.settings.Waves.Tm01(:,1)*3600/XB.settings.SedInput.morfac;
    end

    Hrmstimes = cumsum(XB.settings.Waves.Hrms(:,1));
    Tm01times = cumsum(XB.settings.Waves.Tm01(:,1));
    endtime = XB.settings.Flow.tstop;
    starttime = 0;
    WaveConditions = sort(unique([Tm01times; Hrmstimes; endtime; starttime]));
    for icond = 1:length(WaveConditions)
        if any(Hrmstimes==WaveConditions(icond,1))
            WaveConditions(icond,2) = XB.settings.Waves.Hrms(Hrmstimes==WaveConditions(icond,1),2);
        else
            id = find(Hrmstimes<WaveConditions(icond,1),1,'last');
            if isempty(id)
                id=1;
            end
            WaveConditions(icond,2) = XB.settings.Waves.Hrms(id,2);
        end
        if any(Tm01times==WaveConditions(icond,1))
            WaveConditions(icond,3) = XB.settings.Waves.Tm01(Tm01times==WaveConditions(icond,1),2);
        else
            id = find(Tm01times<WaveConditions(icond,1),1,'last');
            if isempty(id)
                id=1;
            end
            WaveConditions(icond,3) = XB.settings.Waves.Tm01(id,2);
        end
    end
    WaveCond(:,1) = diff(WaveConditions(:,1));
    WaveCond(:,2) = WaveConditions(1:end-1,2);
    WaveCond(:,3) = WaveConditions(1:end-1,3);

    [dummy basefile] = fileparts(XB.settings.Waves.bcfile);
    basefile = strrep(basefile,'.','_');
    XB.settings.Waves.bcfile = 'WaveBoundaryFilelist.bcw';
    fid1  = fopen([calcdir filesep XB.settings.Waves.bcfile],'w');
    fprintf(fid1,'%s\n','FILELIST');

    if isfield(XB.settings.Waves,'df')
        df=XB.settings.Waves.df;
        XB.settings.Waves=rmfield(XB.settings.Waves,'df');
    else
        df=0.005;
    end
    f    = 0.005:df:1.0;
    g=XB.settings.Waves.g;

    for iwavbound = 1:size(WaveCond,1)
        switch XB.settings.Info.WaveBoundType
            case 'PM'
                fpeak= 1/WaveCond(iwavbound,3);
                Ef   = g^2*(2*pi)^-4*f.^-5.*exp(-5/4*(f./fpeak).^-4);
                Hm0t= 4*sqrt(nansum1(Ef*df));
                Ef   = WaveCond(iwavbound,2)^2/Hm0t^2*Ef;
            case 'DP01'
                % read from file
                temp = load('D:\geer\Projects\H5019.00 SBW Duinen\h5019.20 Ontwikkel\Berekeningen\!Gegevens\DP01.spec');
                Ef   = interp1(temp(:,1),temp(:,2),f);
                Ef(isnan(Ef)) = 0;
                Hm0t = 4*sqrt(nansum1(Ef*df));
                Ef   = XB.settings.Waves.Hrms(:,2)^2/Hm0t^2*Ef;
            case 'DP02'
                % read from file
                temp = load('D:\geer\Projects\H5019.00 SBW Duinen\h5019.20 Ontwikkel\Berekeningen\!Gegevens\DP02.spec');
                Ef   = interp1(temp(:,1),temp(:,2),f);
                Ef(isnan(Ef)) = 0;
                Hm0t = 4*sqrt(nansum1(Ef*df));
                Ef   = XB.settings.Waves.Hrms(:,2)^2/Hm0t^2*Ef;
            otherwise % jonswap
                fpeak= 1/WaveCond(iwavbound,3);
                sigma= 0.08;
                gammajs=3.3;
                Ef   = g^2*(2*pi)^-4*f.^-5.*exp(-5/4*(f./fpeak).^-4).*gammajs.^exp(-0.5*((f./fpeak-1)/sigma).^2);
                Hm0t= 4*sqrt(nansum1(Ef*df));
                Ef   = WaveCond(iwavbound,2)^2/Hm0t^2*Ef;
        end
        spectrumfile([calcdir filesep basefile ,'.bc' num2str(iwavbound)],f,Ef);

        nr = 1;
        dur = WaveCond(iwavbound,1);
        if WaveCond(iwavbound,1)/XB.settings.Waves.dthc > 40000
            nr = ceil((WaveCond(iwavbound,1)/XB.settings.Waves.dthc) / 40000);
            dur(1:nr-1) = round(40000*XB.settings.Waves.dthc);
            dur(nr) = WaveCond(iwavbound,1)-sum(dur(1:nr-1));
        end

        for inr = 1:nr
            fprintf(fid1,'%5.3f\t %5.3f\t %s\n',dur(inr),XB.settings.Waves.dthc,[basefile ,'.bc' num2str(iwavbound)]);
        end
    end

    % empty settings field for specification of just one condition.
    [XB.settings.Waves.Hrms XB.settings.Waves.Tm01 XB.settings.Waves.dir0 XB.settings.Waves.dthc XB.settings.Waves.rt ] = deal([]);

    % close boundary filelist
    fclose(fid1);
end

%% create params-file
% get precision
[dummy Precision]=CreateEmptyXBeachVar;

fid = fopen([calcdir filesep 'params.txt'],'w');
fprintf(fid,'%s\n\n',['Automatic generated XBeach parameter settings input file (created: ' datestr(now) ')']);

%% Grid input
fprintf(fid,'%s\n%s\n%s\n','%','%% Grid input','%');
prms=fieldnames(XB.settings.Grid);
spaces = 11-cellfun(@length, prms);
for iprms=1:length(prms)
    if ~isempty(XB.settings.Grid.(prms{iprms}))
        if sum(strcmp(Precision(:,1),prms{iprms}))>0
            Prcs=Precision{strcmp(Precision(:,1),prms{iprms}),2};
        elseif ischar(XB.settings.Grid.(prms{iprms}))
            Prcs='%s';
        else
            Prcs='%g';
        end
        fprintf(fid,['%s %' num2str(spaces(iprms)) 's ' Prcs '\n'], prms{iprms}, '=',XB.settings.Grid.(prms{iprms}));
    end
end
fprintf(fid,'\n');

%% Wave input
fprintf(fid,'%s\n','%','%% Wave input','%');
prms=fieldnames(XB.settings.Waves);
spaces = 11-cellfun(@length, prms);
for iprms=1:length(prms)
    if ~isempty(XB.settings.Waves.(prms{iprms}))
        if sum(strcmp(Precision(:,1),prms{iprms}))>0
            Prcs=Precision{strcmp(Precision(:,1),prms{iprms}),2};
        elseif ischar(XB.settings.Waves.(prms{iprms}))
            Prcs='%s';
        else
            Prcs='%g';
        end
        fprintf(fid,['%s %' num2str(spaces(iprms)) 's ' Prcs '\n'], prms{iprms}, '=',XB.settings.Waves.(prms{iprms}));
    end
end
fprintf(fid,'\n');

%% Flow input
fprintf(fid,'%s\n','%','%% Flow input','%');
prms=fieldnames(XB.settings.Flow);
spaces = 11-cellfun(@length, prms);
for iprms=1:length(prms)
    if ~isempty(XB.settings.Flow.(prms{iprms}))
        if sum(strcmp(Precision(:,1),prms{iprms}))>0
            Prcs=Precision{strcmp(Precision(:,1),prms{iprms}),2};
        elseif ischar(XB.settings.Flow.(prms{iprms}))
            Prcs='%s';
        else
            Prcs='%g';
        end
        fprintf(fid,['%s %' num2str(spaces(iprms)) 's ' Prcs '\n'], prms{iprms}, '=',XB.settings.Flow.(prms{iprms}));
    end
end
fprintf(fid,'\n');

%% Sediment input
fprintf(fid,'%s\n','%','%% Sediment input','%');
prms=fieldnames(XB.settings.SedInput);
spaces = 11-cellfun(@length, prms);
for iprms=1:length(prms)
    if ~isempty(XB.settings.SedInput.(prms{iprms}))
        if sum(strcmp(Precision(:,1),prms{iprms}))>0
            Prcs=Precision{strcmp(Precision(:,1),prms{iprms}),2};
        elseif ischar(XB.settings.SedInput.(prms{iprms}))
            Prcs='%s';
        else
            Prcs='%g';
        end
        fprintf(fid,['%s %' num2str(spaces(iprms)) 's ' Prcs '\n'], prms{iprms}, '=',XB.settings.SedInput.(prms{iprms}));
    end
end
fprintf(fid,'\n');

%% Output specifications
if XB.settings.OutputOptions.nglobalvar ~= XB.settings.Info.nVarOutDef
    fprintf(fid,'%s\n','%','%% Output specifications','%');
    fprintf(fid,'%s %1.0f \n', 'nglobalvar =', XB.settings.OutputOptions.nglobalvar);
    for i=1:length(XB.settings.OutputOptions.OutVars)
        fprintf(fid,'%s\n',XB.settings.OutputOptions.OutVars{i});
    end
end
fclose(fid);