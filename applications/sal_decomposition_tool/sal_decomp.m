function sal_decomp(varargin)
%% sal_decomp decomposition of salinity fluxes into 16 terms (Y.Dijkstra)
%
%   See memo of Y.Dijkstra :
%   memo_salt_balance_diagnostic_tool.pdf 21-Jul-14  13:15
%
%   Syntax: sal_decomp(varargin)
%
%   call without arguments assumes input-file named : zoutflux.ini
%
%   varargin  = optional <keyword ,value> pair ('Filinp','zoutflux_voor_gerben.ini')
%   keyword Filinp can be either a string or a cell array of strings
%
%% example input file:
% -----------------------------------------------------------------
% [Files]
% Mydir       = d:\projects\15-hol_ijssel\runs
% Runid       = y13
% Crs file    = zoutflux.crs
% Output file = zf-y13-00x.tek
% [Timings]
% ana_start   = '20510101  091000'
% ana_stop    = '20511130  220000'
% -----------------------------------------------------------------
%%
%   Output: tekal-file with total and decomposed fluxes.
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 <Deltares>
%       Theo van der Kaaij
%
%       email: Theo.vanderKaaij@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Dec 2015
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $
%% code
%% Initialisation
clearvars -except varargin;

%% Get general information
OPT.Filinp{1}  = 'zoutflux.ini';
OPT           = setproperty(OPT,varargin);

if ~iscell(OPT.Filinp) OPT.Filinp = cellstr(OPT.Filinp);end

for i_sim = 1: length(OPT.Filinp)
    Info        = inifile('open',OPT.Filinp{i_sim});
    mydir       = inifile('get',Info,'Files'  ,'Mydir       ');
    run         = inifile('get',Info,'Files'  ,'Runid       ');
    crsfil      = inifile('get',Info,'Files'  ,'Crs file    ');
    outfil      = inifile('get',Info,'Files'  ,'Output file ');
    start       = inifile('get',Info,'Timings','ana_start   ');
    stop        = inifile('get',Info,'Timings','ana_stop    ');

    %% Construct filenames
    myrun    = ['trih-' run] ;                                       % run id
    mymap    = ['trim-' run] ;
    
    %% Check if trih file exist, if not, generate a list of stations needed for decomposition
    action = 'decomp';
    if ~exist([mydir filesep myrun '.dat'],'file') action = 'initial';end;
    
    %% Read cross section
    crs    = delft3d_io_crs('read',crsfil) ;
    no_crs = crs.NTables ;
    
    %% Determine type of cross section (u or v)
    for i_crs = 1: no_crs
        if crs.DATA(i_crs).mn(1) == crs.DATA(i_crs).mn(3)
            type{i_crs} = 'u';
        else
            type{i_crs} = 'v';
        end
    end
    
    %% decomposition of fluxes
    switch action
        case 'decomp'
            
            %% Read history data
            %  times
            display ('Read data history file ')
            myfile   = [mydir filesep myrun '.dat'];                                          % data file
            T        = vs_time(myfile) ;                                                      % read timesteps
            it_start = find( T.datenum >= datenum(start(2:end-1),'yyyymmdd HHMMSS'),1,'first' ) ;
            it_stop  = find( T.datenum >= datenum(stop (2:end-1),'yyyymmdd HHMMSS'),1,'first' ) ;
            
            %  stations
            trih     = vs_use(myfile);                                                        % open trih file
            stat     = vs_trih_station(trih);                                                 % read stations
            namst    = cellstr(stat.name);                                                    % names monitoring points
            no_stat  = size(namst,1);                                                         % total number monitoring points
            
            %  series
            sal      = vs_let(trih,'his-series',{it_start:it_stop},'GRO',{0 0 1});            % salinity
            zcuru    = vs_let(trih,'his-series',{it_start:it_stop},'ZCURU',{0 0});            % u velocity
            zcurv    = vs_let(trih,'his-series',{it_start:it_stop},'ZCURV',{0 0});            % v velocity
            zwl      = vs_let(trih,'his-series',{it_start:it_stop},'ZWL',{0});                % water level
            dps      = vs_let(trih,'his-series',{it_start:it_stop},'DPS',{0});                % depth (cell centres)
            catos    = vs_let(trih,'his-series',{it_start:it_stop},'ATR',{0 0});              % cumulated advective transport
            
            %  names an coordinates
            mnstat   = squeeze(vs_let(trih,'his-const','MNSTAT')) ;                           % m,n stations
            mntra    = squeeze(vs_let(trih,'his-const','MNTRA')) ;                            % m,n crs-sections
            namtra   = squeeze(vs_let(trih,'his-const','NAMTRA')) ;                           % name crs-sections
            
            
            %% Read const data map file
            display ('Read const data map file ')
            myfile   = [mydir filesep mymap '.dat'];                                          % data file
            trim     = vs_use(myfile);                                                        % open trim file
            
            xcor     = vs_let(trim,'map-const','XCOR');                                       % X-coordinates grid points
            ycor     = vs_let(trim,'map-const','YCOR');                                       % Y-coordinates grid points
            thick    = vs_let(trim,'map-const','THICK');                                      % Thickness layers
            
            %% retrieve data grid data
            G                            = vs_meshgrid2dcorcen(trim);
            guu(2:G.nmax-1,2:G.mmax-1)   = G.cen.guu ;
            gvv(2:G.nmax-1,2:G.mmax-1)   = G.cen.gvv ;
            
            %% Set constants
            kmax     = length(thick)    ;
            mmax     = G.mmax ;
            nmax     = G.nmax ;
            times    = 1:size((sal),1)  ;
            no_times = length(times) ;
            
            %% Calculate areas per timestep per obs-point
            display ('calculate areas per timestep per obs-point (to use in eq.8 of doc. of Yoeri)')
            crsu_area(1:no_times,1:no_stat) = 0;
            crsv_area(1:no_times,1:no_stat) = 0;
            for istat=1:no_stat
                m  = mnstat(1,istat) ;
                n  = mnstat(2,istat) ;
                wd = zwl(:,istat) + dps(:,istat) ;
                for k=1:kmax
                    crs2_u   (:,istat,k) =                     guu(n,m) * thick(k) * wd;
                    crsu_area(:,istat)   =crsu_area(:,istat) + guu(n,m) * thick(k) * wd;         %% calculated areas
                    crs2_v   (:,istat,k) =                     gvv(n,m) * thick(k) * wd;
                    crsv_area(:,istat)   =crsv_area(:,istat) + gvv(n,m) * thick(k) * wd;         %% calculated areas
                end
            end
            
            %% Mask transects
            display ('Mask transects')
            mymask = false(no_stat,no_crs);
            for i_crs =1:no_crs
                for i_pnt =1:length(crs.DATA(i_crs).m)
                    m = crs.DATA(i_crs).m(i_pnt);
                    n = crs.DATA(i_crs).n(i_pnt);
                    i_stat = find(mnstat(1,:) == m & mnstat(2,:) == n) ;
                    mymask(i_stat,i_crs) = true;
                end
                no_crs_tra(i_crs) = find(strcmp(strtrim(crs.DATA(i_crs).name),char2cell(namtra)) ==1) ;
            end
            
            %% Decomposition Yoeri (Loop over transects)
            no_terms = 16;
            terms    = nan(no_crs,no_terms);
            for i_crs=1 :no_crs
                
                %% check transport
                no_pts = length(crs.DATA(i_crs).m);
                no_pts = length(find(mymask(:,i_crs)==1)) ; %Number of stations buiding the crs section derived from the history stations
                if strcmp(type{i_crs},'u')
                    % u section
                    uu=zcuru  (times,mymask(:,i_crs),:);
                    aa=crs2_u (times,mymask(:,i_crs),:);
                else
                    % v section
                    uu=zcurv  (times,mymask(:,i_crs),:);
                    aa=crs2_v (times,mymask(:,i_crs),:);
                end
                ss        =sal  (times,mymask(:,i_crs),:);
                ff        =uu.*ss.*aa;
                fff(i_crs)=mean(sum(sum(ff,3),2));
                
                %% Cross-sections and weights
                if strcmp(type{i_crs},'u')
                    % u section
                    A       = mean(sum(crsu_area(:,mymask(:,i_crs)),2)) ;
                    aap     = sum(crsu_area(:,mymask(:,i_crs)),2) - A ;
                    Avar    = repmat(sum(crsu_area(:,mymask(:,i_crs)),2),[1,no_pts,kmax]);
                    weights = crs2_u(:,mymask(:,i_crs),:)./Avar;
                else
                    % v section
                    A       = mean(sum(crsv_area(:,mymask(:,i_crs)),2)) ;
                    aap     = sum(crsv_area(:,mymask(:,i_crs)),2) - A ;
                    Avar    = repmat(sum(crsv_area(:,mymask(:,i_crs)),2),[1,no_pts,kmax]);
                    weights = crs2_v(:,mymask(:,i_crs),:)./Avar;
                end
                
                %%  velocities uu already determined (zcuru or zcurv)
                ua=CsumTavg(uu.*weights);
                ub=Csum(uu.*weights)-repmat(ua,[no_times,1]);
                uc=Tavg(uu)-repmat(ua,[1, no_pts,kmax]);
                ud=uu-repmat(ub,[1,no_pts,kmax])- ...
                    repmat(uc,[no_times,1,1]) - ...
                    repmat(ua,[no_times,no_pts,kmax]);
                
                %%  salinities ss already determined
                sa=CsumTavg(ss.*weights);
                sb=Csum(ss.*weights)-repmat(sa,[no_times,1]);
                sc=Tavg(ss)-repmat(sa,[1, no_pts,kmax]);
                sd=ss-repmat(sb,[1,no_pts,kmax])- ...
                    repmat(sc,[no_times,1,1]) - ...
                    repmat(sa,[no_times,no_pts,kmax]);
                
                %% Construct the terms
                term(1) =sa*ua*A;
                term(2) =sa*Tavg(ub.*aap);
                term(3) =sa*CsumTavg(repmat(uc,[no_times,1,1]).*weights.*Avar);
                term(4) =sa*CsumTavg(ud.*weights.*Avar);
                
                term(5) =ua*Tavg(sb.*aap);
                term(6) =Tavg(ub.*sb.*(A+aap));
                term(7) =Tavg(sb.*Csum(uc.*Tavg(weights)).*aap);
                term(8) =Tavg(sb.*Csum(ud.*weights).*(A+aap));
                
                term(9) =ua*CsumTavg(repmat(sc,[no_times,1,1]).*Avar.*weights);
                term(10)=Tavg(ub.*Csum(sc.*Tavg(weights)).*aap);
                term(11)=Csum(Tavg(weights).*uc.*sc*A);
                term(12)=Csum(Tavg(weights).*sc.*Tavg(ud.*Avar));
                
                term(13)=ua*CsumTavg(sd.*Avar.*weights);
                term(14)=Tavg(ub.*Csum(sd.*weights).*(A+aap));
                term(15)=Csum(uc.*Tavg(sd.*Avar).*Tavg(weights));
                term(16)=CsumTavg(sd.*ud.*Avar.*weights);
                
                %% Store
                terms(i_crs,1:length(term))=term;
            end
            
            %% Print to output file
            %  opening output file and general information
            fid =fopen (outfil,'w')             ;
            fprintf (fid,'%s \n','* -------------------------------------------------------------------------') ;
            fprintf (fid,'%s %s\n','* run   : ',run) ;
            fprintf (fid,'%s %s\n','* start : ',start) ;
            fprintf (fid,'%s %s\n','* stop  : ',stop) ;
            fprintf (fid,'%s \n','* -------------------------------------------------------------------------') ;
            fprintf (fid,'%s \n','* mtx       = riverflux + tideflux + variationflux') ;
            fprintf (fid,'%s \n','* ') ;
            fprintf (fid,'%s \n','* river     = term1') ;
            fprintf (fid,'%s \n','* tide      = term2 + term5 + term6') ;
            fprintf (fid,'%s \n','* variation = term3 + term4 + term7 + term8 + (term9 until 16)') ;
            fprintf (fid,'%s \n','* ') ;
            
            %   1234567890112345678901123456789011234567890112345678901123456789011234567890112345678901123456789011234567890112345678901 12345678901
            fprintf (fid,'%s%s%s \n','* cs       check  check_atr        mtx      river       tide  variation     dummy      ',...
                'term1      term2      term3      term4      term5      term6      term7      term8      ',... ;
                'term9     term10     term11     term12     term13     term14     term15     term16') ;
            
            fprintf (fid,'%s \n',   'BL01') ;
            fprintf (fid,'%4i %i \n',no_crs, 24) ;
            
            %% Print the results (the decomposed fluxes)
            for i_crs = 1: no_crs
                %% Combine
                mtx      = sum(terms(i_crs,1:end));
                river    =     terms(i_crs,1    )     ;
                tide     =     terms(i_crs,2    )  + sum(terms(i_crs,5: 6));
                variation= sum(terms(i_crs,3:4  )) + sum(terms(i_crs,7:16));
                dummy    = 999.999;
                
                %% print to file
                fprintf (fid,['%4i  ' repmat('%10.3f ',1,no_terms + 7) ' \n'], i_crs, fff(i_crs), catos(end,no_crs_tra(i_crs))/(T.t(end)-T.t(1)),mtx, ...
                    river,tide,variation,dummy,terms(i_crs,:));
            end
            
            fclose(fid);
            
            %% A second file with matrix of mean max and min salinities
            point   = strfind(outfil,'.');
            outfil = [outfil(1:point(end)-1) '.map'];
            fid     = fopen (outfil,'w');
            
            for i_crs = 1: no_crs
                
                % averaging, maximum and minimum
                dp_mean(i_crs)  = -1.0*mean(mean(dps(:,mymask(:,i_crs))));
                s1_mean(i_crs)  =      mean(mean(zwl(:,mymask(:,i_crs))));
                sal_mean(i_crs,:) =      mean(mean(sal(:,mymask(:,i_crs),:),2),1);
                sal_max (i_crs,:) =      max (mean(sal(:,mymask(:,i_crs),:),2),[],1);
                sal_min (i_crs,:) =      min (mean(sal(:,mymask(:,i_crs),:),2),[],1);
                
                % positions
                x(i_crs,1) = i_crs;
                y(i_crs,1) = s1_mean(i_crs) - 0.5*thick(1)*(s1_mean(i_crs) - dp_mean(i_crs));
                for k = 2:kmax
                    x(i_crs,k) = i_crs;
                    y(i_crs,k) = y(i_crs,k-1) - thick(k)*(s1_mean(i_crs) - dp_mean(i_crs));
                end
            end
            
            % write to output file
            fprintf(fid,'* Salinities \n');
            fprintf(fid,'* Column 1: x-coordinate (cross section number) \n');
            fprintf(fid,'* Column 2: y-coordinate                        \n');
            fprintf(fid,'* Column 3: mean salinity                       \n');
            fprintf(fid,'* Column 4: maximum salinity                    \n');
            fprintf(fid,'* Column 5: minimum salinity                    \n');
            fprintf(fid,'Salinity                                        \n');
            fprintf(fid,[repmat(' %5i',1,4) '\n' ],no_crs*kmax,5,kmax,no_crs);
            for i_crs = 1: no_crs
                for k = 1: kmax
                    fprintf(fid,[' %5i' repmat(' %12.6f',1,4) '\n'],x       (i_crs,k),y      (i_crs,k), ...
                        sal_mean(i_crs,k),sal_max(i_crs,k), ...
                        sal_min (i_crs,k)                 );
                end
            end
            
            %% Close tekal file
            fclose(fid) ;
        case 'initial'
            no_sta = 0;
            for i_crs = 1: no_crs
                m(1) = crs.DATA(i_crs).mn(1);
                m(2) = crs.DATA(i_crs).mn(3);
                n(1) = crs.DATA(i_crs).mn(2);
                n(2) = crs.DATA(i_crs).mn(4);
                m    = sort(m);
                n    = sort(n);
                for i = m(1):m(2)
                    for j = n(1):n(2)
                        no_sta    = no_sta + 1;
                        obs.m(no_sta)     = i;
                        obs.n(no_sta)     = j;
                        obs.namst{no_sta} = ['(M,N) = (' num2str(obs.m(no_sta),' %4i') ','...
                                                         num2str(obs.n(no_sta),' %4i') ')'];
                        no_sta    = no_sta + 1;
                        switch type{i_crs}
                            case 'u'
                                obs.m(no_sta) = i + 1;
                                obs.n(no_sta) = j;
                            case 'v'
                                obs.m(no_sta) = i;
                                obs.n(no_sta) = j+1;
                        end
                        obs.namst{no_sta} = ['(M,N) = (' num2str(obs.m(no_sta),' %4i') ','...
                                                         num2str(obs.n(no_sta),' %4i') ')'];
                    end
                end
            end
            filobs = [mydir filesep 'sal_decomp_' run '.obs'];
            delft3d_io_obs('write',filobs,obs);
    end
    clearvars -except OPT;
end

end
%% Csum cross-section-summation
function out=Csum(in)

out=sum(sum(in,3),2);

end

%% Tavg time-average function
function out=Tavg(in)

out=mean(in,1);

end

%% CsumTavg cross-section-summation and time-average function
function out=CsumTavg(in)

out=mean(sum(sum(in,3),2),1);

end
