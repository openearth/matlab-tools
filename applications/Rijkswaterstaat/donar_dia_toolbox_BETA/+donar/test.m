%% Test for donar toolbox with novel data from from Rijkswaterstaat ship Zirfaea
%  * CTD(station,z,t) 1D profiles
%  * FerryBox(x,y,t) 2D trajectory (fixed z)
%  * MeetVis(x,y,z,t) 3D trajectory (undulating)
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
OPT.plot  = 0;
diafiles  = {'\raw\ferry_2005_-_2012_shortened.dia'};
diafiles  = {'raw\CTD\raw\ctd_1998_-_1999.dia',...       %  40 s,  50 Mb, 3562 blocks
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

E = nc2struct([root,'\opendap.deltares.nl\thredds\dodsC\opendap\rijksoverheid\eez\Exclusieve_Economische_Zone_maart2012.nc']);
L = nc2struct([root,'\opendap.deltares.nl\thredds\dodsC\opendap\deltares\landboundaries\northsea.nc']);

for ifile = 2 %:length(diafiles);
    
  disp(['File: ',num2str(ifile)])

  diafile = [basedir,filesep,diafiles{ifile}];
  File    = donar.open(diafile,'cache',OPT.cache,'disp',1000);
  donar.disp(File)

  if OPT.read
     ncolumn = 6;
     for ivar = 1%:length(File.Variables);
    
        [D,M0] = donar.read(File,ivar,ncolumn);
        %%
        close
        % each profile_id seems to be in a seperate block !
        if type(ifile)==1
           [S,M ] = donar.ctd_struct(D,M0);
            if 1 %OPT.plot
            subplot(3,2,1)
            plot(S.datenum,S.profile_id)
            hold on
            plot(S.datenum,S.block,'r--')
            datetick('x')
            ylabel({'profile\_id ','== dia block id ??'})
            grid on
            subplot(3,2,3)        
            plot(S.datenum,[0;diff(S.datenum)])
            datetick('x')
            ylabel('dt')
            grid on
            subplot(3,2,5)        
            plot(S.datenum,S.station_id)
            datetick('x')
            ylabel('station\_id')
            grid on    
            
            subplot(3,2,[2 4 6])
            scatter(S.station_lon,S.station_lat,50,log10(S.station_n),'filled')
            hold on
            text(S.station_lon,S.station_lat,num2str([1:length(S.station_lat)]',' %d'))
            plot(L.lon,L.lat,'-' ,'color',[0 0 0])
            plot(E.lon,E.lat,'--','color',[0 0 0])        
            grid on
            axis([-2 9 50 57])    
            axislat
            tickmap('ll')
            clim(log10([1 1e5]))
            colormap(clrmap(jet,5*2))
            [h,~]=colorbarwithhtext('number of profiles',log10([1 10 100 1000 1e4 1e5]),'horiz')
            set(h,'xticklabel',{'1','10','100','1000','1e4','1e5'});
            end
            print2screensize(strrep(diafile,'.dia',['_',M.data.WNS,'_ctd.png']))
        elseif type(ifile)==2
           [S,M ] = donar.trajectory_struct(D,M0);
            if OPT.plot
            close all
            scatter(S.lon,S.lat,40,S.data,'.')
            hold on
            plot(L.lon,L.lat,'-' ,'color',[0 0 0])
            plot(E.lon,E.lat,'--','color',[0 0 0])
            colorbarwithvtext([M.data.long_name,'[',M.data.units,']'])
            grid on
            axis([-2 9 50 57])    
            axislat
            title(mktex(diafiles{ifile}))
            print2a4(strrep(diafile,'.dia',['_',M.data.WNS,'_trajectory.png']),'v','w')
            end           
        end
        
     end % ivar
     
  end % read
  
end % diafiles    
