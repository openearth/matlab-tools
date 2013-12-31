%% Test for donar toolbox with novel data from from Rijkswaterstaat ship Zirfaea
%  * CTD     (station,z,t) 1D profiles at series of fixed positions
%  * FerryBox(x,y      ,t) 2D trajectory (fixed z)
%  * MeetVis (x,y    ,z,t) 3D trajectory (undulating z)
%  requested at helpdeskwater.nl
%
%See also: rws_waterbase

clc;clear all;fclose all;tic;profile on
profile clear

root = 'x:\D'; % VM
root = 'D:\';

basedir   = [root,'\P\1209005-eutrotracks'];

OPT.cache = 1; % donar.open() cache
OPT.read  = 1;
OPT.plot  = 1;
OPT.case  = 'ferry';

switch OPT.case
case '0',
    diafiles  = {'raw\CTD\raw\ctd_1998_-_1999.dia',...        %  40 s,  50 Mb, 3562 blocks
                 'raw\CTD\raw\ctd_2000_-_2002.dia',...        %  97 s,  63 Mb, 5815 blocks
                 'raw\CTD\raw\ctd_2003_-_2009.dia',...        % 150 s,  69 Mb, 4815 blocks
                 'raw\CTD\raw\ctd_2011_-_2012.dia',...        % 133 s,  11 Mb,  133 blocks
                 ...
                 'raw\FerryBox\raw\ferry_2005_-_2012.dia',... % 214 s, 120 Mb,  880 blocks
                 ...
                 'raw\ScanFish\raw\meetv_1998_-_1999.dia',... % 254 s,  73 Mb, 1501 blocks
                 'raw\ScanFish\raw\meetv_2000_-_2002.dia',... % 325 s, 133 Mb, 2124 blocks
                 'raw\ScanFish\raw\meetv_2003_-_2009.dia',... % 479 s, 290 Mb, 4032 blocks
                 'raw\ScanFish\raw\meetv_2011_-_2012.dia'};   % 493 s,  26 Mb,  400 blocks
    type = [1 1 1 1   2 2   3 3 3 3]; % 1=CTD profiles, 2=2Dtrajectory (fixed Z), 3=3Dtrajectory (undulating z)
case 'ctd',
    diafiles  = {'raw2\ctd_1.dia',... % 02-Jun-1999 02:51:33 - 03:03:19: 1 profile  = 2 dia blocks
                 'raw2\ctd_2.dia',...
                 'raw2\ctd_3.dia',...
                 'raw2\ctd_4.dia',...
                 'raw2\ctd_5.dia',...
                 'raw2\ctd_6.dia',...
                 'raw2\ctd_7.dia',...
                 'raw2\ctd_8.dia'}; 
    type = [1 1 1 1 1 1 1 1]; % 1=CTD profiles, 2=2Dtrajectory (fixed Z), 3=3Dtrajectory (undulating z)
case 'meetv',
        diafiles  = {'raw2\meetv_1.dia',... % 02-Jun-1999 02:51:33 - 03:03:19: 1 profile  = 2 dia blocks
                     'raw2\meetv_2.dia',...
                     'raw2\meetv_3.dia',...
                     'raw2\meetv_4.dia',...
                     'raw2\meetv_5.dia',...
                     'raw2\meetv_6.dia',...
                     'raw2\meetv_7.dia'}; 
        type = [3 3 3 3 3 3 3]; % 1=CTD profiles, 2=2Dtrajectory (fixed Z), 3=3Dtrajectory (undulating z)
case 'ferry',
    diafiles  = {'raw2\ferry_4.dia',... % 02-Jun-1999 02:51:33 - 03:03:19: 1 profile  = 2 dia blocks
                 'raw2\ferry_5.dia',...
                 'raw2\ferry_6.dia',...
                 'raw2\ferry_7.dia',...
                 'raw2\ferry_8.dia'}; 
    type = [2 2 2 2 2]; % 1=CTD profiles, 2=2Dtrajectory (fixed Z), 3=3Dtrajectory (undulating z)
otherwise
end

E = nc2struct([root,'\opendap.deltares.nl\thredds\dodsC\opendap\rijksoverheid\eez\Exclusieve_Economische_Zone_maart2012.nc']);
L = nc2struct([root,'\opendap.deltares.nl\thredds\dodsC\opendap\deltares\landboundaries\northsea.nc']);

for ifile = 1:length(diafiles);
    
  disp(['File: ',num2str(ifile)])

  diafile = [basedir,filesep,diafiles{ifile}];
  File    = donar.open(diafile,'cache',OPT.cache,'disp',1000);
  donar.disp(File)
%%
  if OPT.read
     ncolumn = 6;
     for ivar = find(strcmp({File.Variables.standard_name},'sea_water_salinity')) %:length(File.Variables);
    
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
          donar.ctd_overview_plot(S,M,E,L)
          print2a4(strrep(diafile,'.dia',['_',M.data.WNS,'_ctd.png']))
            for ist=1:length(S.station_lon)
                disp(['processing ctd ',num2str(ist),'/',num2str(length(S.station_lon))])
                ind = (S.station_id==ist);
                clear P
                P = donar.ctd_timeSeriesProfile(S,ind);
                if OPT.plot % per profile
                    titletxt = [num2str(ist),' (n=',num2str(S.station_n(ist)),') :',num2strll(S.station_lat(ist),S.station_lon(ist))];
                    close
                    donar.ctd_timeSeriesProfile_plot(P,E,L,titletxt)
                    donar.ctd_timeSeriesProfile2nc(strrep(diafile,'.dia',['_',M.data.WNS,'_ctd_',num2str(ist,'%0.3d'),'.nc' ]),P,M)
                    print2a4                      (strrep(diafile,'.dia',['_',M.data.WNS,'_ctd_',num2str(ist,'%0.3d'),'.png']),'v','t')
                    close
                end
            end
          end
        elseif type(ifile)==2
          if OPT.plot
            close all
            donar.trajectory_overview_plot(S,M,E,L,mktex(diafiles{ifile}))
            print2screensize(strrep(diafile,'.dia',['_',M.data.WNS,'_trajectory.png']))
          end           
        end
        
     end % ivar
     
  end % read
  
end % diafiles    

% D:\\P\1209005-eutrotracks\raw2\ctd_1.dia
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
