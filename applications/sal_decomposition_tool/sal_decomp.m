function sal_decomp(varargin)
%% sal_decomp decomposition of salinity fluxes into 16 terms (Y.Dijkstra)
%
%   See memo of Y.Dijkstra :
%   memo_salt_balance_diagnostic_tool.pdf 21-Jul-14  13:15
% 
%   Syntax:
%   varargout = sal_decomp(varargin)
%
%   Input: For <keyword,value> pairs call sal_decomp() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   sal_decomp
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 <COMPANY>
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
clearvars -except varargin; hold off; close all; fclose all;
no_terms = 16;

%% Get general information
Opt.Filinp  = 'zoutflux-00x.ini';
Opt         = setproperty(Opt,varargin);

Info        = inifile('open',Opt.Filinp);
mydir       = inifile('get',Info,'Files'  ,'Mydir       ');
run         = inifile('get',Info,'Files'  ,'Runid       ');
crs_tmp     = inifile('get',Info,'Files'  ,'Crs file    ');
output      = inifile('get',Info,'Files'  ,'Output file ');
start       = inifile('get',Info,'Timings','ana_start   ');
stop        = inifile('get',Info,'Timings','ana_stop    ');

%% Construct filenames
    mydir    = ['d:\projects\15-hol_ijssel\runs\' run filesep];      % run dir.
myrun    = ['trih-' run] ;                             % run id
mymap    = ['trim-' run] ;
outfil   = [mydir output];                         
crsfil   = [mydir crs_tmp] ;

%% Read cross section
crs= delft3d_io_crs('read',crsfil) ;
no_crs = crs.NTables ;

%% Read history data
display ('Read data history file ')
myfile = [mydir myrun '.dat'];                                   %% data file
str1   = vs_use(myfile);                                         %% open trih file
T      = vs_time(myfile) ;                                       %% read timesteps
it_start = find( T.datenum >= datenum(start(2:end-1),'yyyymmdd HHMMSS'),1,'first' ) ;
it_stop  = find( T.datenum >= datenum(stop (2:end-1),'yyyymmdd HHMMSS'),1,'first' ) ;

str3   = vs_trih_station(str1);                                  %% read stations
namst  = cellstr(str3.name);                                     %% names monitoring points
no_stat= size(namst,1);                                          %% total number monitoring points

sal    = vs_let(str1,'his-series',{it_start:it_stop},'GRO',{0 0 1});            %% salinity
zcuru  = vs_let(str1,'his-series',{it_start:it_stop},'ZCURU',{0 0});            %% u velocity
zwl    = vs_let(str1,'his-series',{it_start:it_stop},'ZWL',{0});                %% water level
dps    = vs_let(str1,'his-series',{it_start:it_stop},'DPS',{0});                %% depth
mnstat = squeeze(vs_let(str1,'his-const','MNSTAT')) ;            %% m,n stations
mntra  = squeeze(vs_let(str1,'his-const','MNTRA')) ;             %% m,n crs-sections
namtra = squeeze(vs_let(str1,'his-const','NAMTRA')) ;             %% name crs-sections
catos  = vs_let(str1,'his-series',{it_start:it_stop},'ATR',{0 0});              %% cumulated advective transport

%% Read const data map file
display ('Read const data map file ')
myfil2 = [mydir mymap '.dat'];                                   %% data file
str4   = vs_use([mydir mymap '.dat']);                           %% open trim file

xcor   = vs_let(str4,'map-const','XCOR');                        %% X-coordinates grid points
ycor   = vs_let(str4,'map-const','YCOR');                        %% X-coordinates grid points
thick  = vs_let(str4,'map-const','THICK');                       %% Thickness layers

%% retrieve data grid data
G                        = vs_meshgrid2dcorcen(str4);
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
for istat=1:no_stat
    m  = mnstat(1,istat) ;
    n  = mnstat(2,istat) ;
    wd = zwl(:,istat) + dps(:,istat) ;
    for k=1:kmax
        crs2     (:,istat,k) =                     guu(n,m) * thick(k) * wd;
        crsu_area(:,istat)   =crsu_area(:,istat) + guu(n,m) * thick(k) * wd;         %% calculated areas
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
terms = nan(no_crs,no_terms);
for i_crs=1 :no_crs

    %% check transport
    no_pts = length(crs.DATA(i_crs).m);
    no_pts = length(find(mymask(:,i_crs)==1)) ; %Number of stations buiding the crs section derived from the history stations

    uu=zcuru(times,mymask(:,i_crs),:);
    ss=sal  (times,mymask(:,i_crs),:);
    aa=crs2 (times,mymask(:,i_crs),:);
    ff=uu.*ss.*aa;
    fff(i_crs)=mean(sum(sum(ff,3),2));
    
    %% Cross-sections and weights
    A  = mean(sum(crsu_area(:,mymask(:,i_crs)),2)) ;
    aap= sum(crsu_area(:,mymask(:,i_crs)),2) - A ;
    Avar = repmat(sum(crsu_area(:,mymask(:,i_crs)),2),[1,no_pts,kmax]);
    weights = crs2(:,mymask(:,i_crs),:)./Avar;

    %%  velocities
    uu=zcuru(times,mymask(:,i_crs),:);
    ua=CsumTavg(uu.*weights);
    ub=Csum(uu.*weights)-repmat(ua,[no_times,1]);
    uc=Tavg(uu)-repmat(ua,[1, no_pts,kmax]);
    ud=uu-repmat(ub,[1,no_pts,kmax])- ...
        repmat(uc,[no_times,1,1]) - ...
        repmat(ua,[no_times,no_pts,kmax]);

    %%  salinities
    ss=sal(times,mymask(:,i_crs),:);
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
fprintf (fid,'%s \n','* mtx   =qsa+aubsbs+aucscs+udsds') ;
fprintf (fid,'%s \n','* ') ;
fprintf (fid,'%s \n','* qsa   =term1+term2+term3 ') ;
fprintf (fid,'%s \n','* aucscs=term4+term5+term6') ;
fprintf (fid,'%s \n','* aubsbs=term7+term8+term9+term10+term11') ;
fprintf (fid,'%s \n','* udsds =term12+term13+term14+term15+term16') ;
fprintf (fid,'%s \n','* ') ;

%   1234567890112345678901123456789011234567890112345678901123456789011234567890112345678901123456789011234567890112345678901 12345678901
    fprintf (fid,'%s%s%s \n','* cs       check  check_atr        mtx        qsa     aubsbs     aucscs        udscs      ',...
       'term1      term2      term3      term4      term5      term6      term7      term8      ',... ;
       'term9     term10     term11     term12     term13     term14     term15     term16') ;

fprintf (fid,'%s \n',   'BL01') ;
fprintf (fid,'%4i %i \n',no_crs, 24) ;

%% Print the results (the decomposed fluxes)
for i_crs = 1: no_crs
    %% Combine
    mtx   =sum(terms(i_crs,1:end));
    qsa   =sum(terms(i_crs, 1: 4));
    aubsbs=sum(terms(i_crs, 5: 8));
    aucscs=sum(terms(i_crs, 9:12));
    udsds =sum(terms(i_crs,13:16));
    
    %% print to file
    fprintf (fid,['%4i  ' repmat('%10.3f ',1,no_terms + 7) ' \n'], i_crs, fff(i_crs), catos(end,no_crs_tra(i_crs))/(T.t(end)-T.t(1)),mtx, ...
                                                                   qsa,aubsbs,aucscs,udsds,terms(i_crs,:));
end
    
%% Close all files
fclose('all') ;

