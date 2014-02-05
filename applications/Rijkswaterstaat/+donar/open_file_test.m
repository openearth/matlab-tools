%open_file_test test donar.open_file, to test delivered dia batches
%
% Test for donar toolbox with novel data from from Rijkswaterstaat ship Zirfaea
%  * CTD     (station,z,t) 1D profiles at series of fixed positions
%  * FerryBox(x,y      ,t) 2D trajectory (fixed z)
%  * MeetVis (x,y    ,z,t) 3D trajectory (undulating z)
%  requested at helpdeskwater.nl
%
% -----+----+------+--------+--------+-----------------------------------------------------------------+---------->
% File |WNS | # of |   # of |   DONAR|                                                              CF | DONAR
% index|code|blocks|  values|    name|                                         standard_name [UDunits] | long_name [EHD]
% -----+----+------+--------+--------+-----------------------------------------------------------------+---------->
%     1|1926|    11|   46414|   INSLG|               downwelling_radiance_in_sea_water [microEinstein] | Irradiation in uE in surface water [uE]
%     2| 209|    11|   69671|     %O2|             fractional_saturation_of_oxygen_in_sea_water [0.01] | Percentage oxygen in % in surface water [%]
%     3|2392|    11|   52981|  GELDHD|                        sea_water_electrical_conductivity [mS/m] | Conductivity in mS/m with respect to 20 degrees celsius in surface water [mS/m]
%     4| 360|    11|  167320|      O2|                mass_concentration_of_oxygen_in_sea_water [mg/l] | Oxygen in mg/l in surface water [mg/l]
%     5| 377|    11|  162096|      pH|                        sea_water_ph_reported_on_total_scale [1] | Acidity in surface water [DIMSLS]
%     6|  44|    11|   81036|       T|                          sea_water_temperature [degree_Celsius] | Temperature in oC in surface water [oC]
%     7|5108|    11|  143827| TROEBHD|                                       sea_water_turbidity [NTU] | Turbidity in NTU in surface water [NTU]
%     8| 555|    11|  166163|FLUORCTE|                                      sea_water_fluorescence [1] | Fluorescence in U in surface water [U]
%     9| 559|    11|  167318|  SALNTT|                                          sea_water_salinity [1] | Salinity in surface water [DIMSLS]
%    10|7647|    11|    2259|  GELSHD|                               speed_of_sound_in_sea_water [m/s] | Speed of sound in m/s in surface water [m/s]
%    11|7788|    11|   46392|   INSLG|            downwelling_longwave_radiance_in_air [microEinstein] | Irradiation in uE in air [uE]
% -----+----+------+--------+--------+-----------------------------------------------------------------+---------->
%
%See also: rws_waterbase

clc;clear all;fclose all;tic;profile on
profile clear

root = 'x:\D'; % VMware
root = 'D:\';

E = nc2struct([root,'\opendap.deltares.nl\thredds\dodsC\opendap\rijksoverheid\eez\Exclusieve_Economische_Zone_maart2012.nc']);
L = nc2struct([root,'\opendap.deltares.nl\thredds\dodsC\opendap\deltares\landboundaries\northsea.nc']);
%E = nc2struct(['p:\1209005-eutrotracks\ldb\eez\Exclusieve_Economische_Zone_maart2012.nc']);
%L = nc2struct(['p:\1209005-eutrotracks\ldb\landboundaries\northsea.nc']);

basedir   = ['P:\1209005-eutrotracks\'];
basedir   = [root,'\P\1209005-eutrotracks'];

OPT.cache = 1; % donar.open() cache
OPT.read  = 1;
OPT.plot  = 1;
OPT.case  = 'ferry'; %'ferry';
OPT.pause = 0;

switch OPT.case

% dec 2013 delivery: unzipped 'zip2 to folders below, sorting into ctd/ferry/meetv

case 'ctd',
    diafiles  = {'raw2\ctd\ctd_1.dia',... % 02-Jun-1999 02:51:33 - 03:03:19: 1 profile  = 2 dia blocks
                 'raw2\ctd\ctd_2.dia',...
                 'raw2\ctd\ctd_3.dia',...
                 'raw2\ctd\ctd_4.dia',...
                 'raw2\ctd\ctd_5.dia',...
                 'raw2\ctd\ctd_6.dia',...
                 'raw2\ctd\ctd_7.dia',...
                 'raw2\ctd\ctd_8.dia'}; 
    type = [1 1 1 1 1 1 1 1]; % 1=CTD profiles, 2=2Dtrajectory (fixed Z), 3=3Dtrajectory (undulating z)
case 'ferry',
    diafiles  = {'raw2\ferry\ferry_4.dia',... % 02-Jun-1999 02:51:33 - 03:03:19: 1 profile  = 2 dia blocks
                 'raw2\ferry\ferry_5.dia',...
                 'raw2\ferry\ferry_6.dia',...
                 'raw2\ferry\ferry_7.dia',...
                 'raw2\ferry\ferry_8.dia'}; 
    type = [2 2 2 2 2]; % 1=CTD profiles, 2=2Dtrajectory (fixed Z), 3=3Dtrajectory (undulating z)
case 'meetv',
    diafiles  = {'raw2\meetv\meetv_1.dia',... % 02-Jun-1999 02:51:33 - 03:03:19: 1 profile  = 2 dia blocks
                 'raw2\meetv\meetv_2.dia',...
                 'raw2\meetv\meetv_3.dia',...
                 'raw2\meetv\meetv_4.dia',...
                 'raw2\meetv\meetv_5.dia',...
                 'raw2\meetv\meetv_6.dia',...
                 'raw2\meetv\meetv_7.dia'}; 
    type = [3 3 3 3 3 3 3]; % 1=CTD profiles, 2=2Dtrajectory (fixed Z), 3=3Dtrajectory (undulating z)
otherwise
end

%%

for ifile = 1:length(diafiles);
    
  disp(['File: ',num2str(ifile)])

  diafile = [basedir,filesep,diafiles{ifile}];
  File    = donar.open_file(diafile,'cache',OPT.cache,'disp',1000);

  if OPT.read
     ncolumn = 6; % dia syntax
    %for ivar = find(strcmp({File.Variables.standard_name},'sea_water_salinity')) %
     for ivar = 1:length(File.Variables);
    
        [D,M0] = donar.read(File,ivar,ncolumn);
        %% convert
        if type(ifile)==1 % each profile_id seems to be in a seperate block": profile_id==block
           [S,M ] = donar.ctd_struct       (D,M0);%save('ctd.mat','-struct','S')
        else
           [S,M ] = donar.trajectory_struct(D,M0);%save('trajectory.mat','-struct','S')
        end
        
        %% make netCDF file per station: they are disconnected anyway:
        %  only taken when boat does not move (unlike Ferrybox)
        
        if type(ifile)==1
         close all
         if OPT.plot % overview
             
            tmp = donar.resolve_wns(M.data.WNS,'request','struct');
            if isempty(tmp.valid_min{1})
                tmp.valid_min    = nan;
            else
                tmp.valid_min    = str2num(tmp.valid_min{1});
            end
            if isempty(tmp.valid_max{1})
                tmp.valid_max    = nan;
            else
                tmp.valid_max    = str2num(tmp.valid_max{1});
            end             
         
            file.png = strrep(diafile,'.dia',['_',M.data.deltares_name,'_ctd.png']);

            close all % to avoid memory crash
            donar.ctd_overview_plot(S,M,E,L)
            print2a4(file.png,'p','w',200,'o')
            for ist=1:length(S.station_lon)
            
             file.nc  = strrep(diafile,'.dia',['_',M.data.deltares_name,'_ctd_',num2str(ist,'%0.3d'),'.nc' ]);
             file.png = strrep(diafile,'.dia',['_',M.data.deltares_name,'_ctd_',num2str(ist,'%0.3d'),'.png' ]);
             
             file.nc  = strrep(file.nc ,'raw2','nc2');
             file.png = strrep(file.png,'raw2','png2');

             disp(['processing ctd ',num2str(ist),'/',num2str(length(S.station_lon))])
             ind = (S.station_id==ist);
             clear P
             P = donar.ctd_timeSeriesProfile(S,ind);
             donar.ctd_timeSeriesProfile2nc(file.nc,P,M)
            [P2,M2] = nc2struct(file.nc,'rename',{{donar.resolve_wns(M.data.WNS)},{'data'}});
             if OPT.plot % per profile
                titletxt = [num2str(ist),' (n=',num2str(S.station_n(ist)),') :',num2strll(S.station_lat(ist),S.station_lon(ist))];
                close
                close all % to avoid memory crash
                if ivar==1
                donar.ctd_timeSeriesProfile_plot(P,E,L,titletxt,'colorfield','z','colorlabel','z [cm]')
                print2a4(strrep(file.png,M.data.deltares_name,'z'),'v','t',200,'o')
                end
                donar.ctd_timeSeriesProfile_plot(P,E,L,titletxt,'colorfield','data','colorlabel',mktex([M.data.long_name,'[',M.data.units,']']),'clims',[tmp.valid_min, tmp.valid_max])
                print2a4(file.png,'v','t',200,'o')
                close
             end
            end
         end
        elseif type(ifile)==2
        
            file.nc  = strrep(diafile,'.dia',['_',M.data.deltares_name,'_ferry.nc' ]);
            file.png = strrep(diafile,'.dia',['_',M.data.deltares_name,'_ferry.png']);
            file.fig = strrep(diafile,'.dia',['_',M.data.deltares_name,'_ferry.fig']);
            
            file.nc  = strrep(file.nc ,'raw2','nc2' );
            file.png = strrep(file.png,'raw2','png2');
            file.fig = strrep(file.fig,'raw2','fig2');
            
            donar.trajectory2nc(file.nc,S,M)
           %[S2,M2] =  nc2struct(strrep(diafile,'.dia',['_',M.data.deltares_name,'_ferrybox.nc' ]),'rename',{{M.data.deltares_name},{'data'}});
            if OPT.plot
            %close all
            tmp = donar.resolve_wns(M.data.WNS,'request','struct');
            if isempty(tmp.valid_min{1})
                tmp.valid_min    = nan;
            else
                tmp.valid_min    = str2num(tmp.valid_min{1});
            end
            if isempty(tmp.valid_max{1})
                tmp.valid_max    = nan;
            else
                tmp.valid_max    = str2num(tmp.valid_max{1});
            end
            close all % to avoid memory crash
            donar.trajectory_overview_plot(S,M,E,L,mktex(diafiles{ifile}),[tmp.valid_min, tmp.valid_max])
            print2screensizeoverwrite(file.png)
            saveas(gcf,file.fig)
            end           
        elseif type(ifile)==3
           % TO DO
        end
        
        if OPT.pause
           pausedisp
        end
        
     end % ivar
     
  end % read
  
end % diafiles    
