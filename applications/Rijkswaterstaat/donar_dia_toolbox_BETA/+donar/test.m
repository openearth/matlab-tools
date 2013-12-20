%% Test for donar toolbox with novel data from from Rijkswaterstaat ship Zirfaea
%  * CTD     (station,z,t) 1D profiles at series of fixed positions
%  * FerryBox(x,y      ,t) 2D trajectory (fixed z)
%  * MeetVis (x,y    ,z,t) 3D trajectory (undulating z)
%  requested at helpdeskwater.nl
%
%See also: rws_waterbase

clc;clear all;fclose all;tic;profile on
profile clear

root = 'D:\';
root = 'x:\D'; % VM

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
        %% convert
        if type(ifile)==1
            % each profile_id seems to be in a seperate block !
           [S,M ] = donar.ctd_struct(D,M0);
            save('ctd.mat','-struct','S')
        else
           [S,M ] = donar.trajectory_struct(D,M0);
            save('trajectory.mat','-struct','S')
        end
        %%
        S = load('ctd')
        edges = [0 1 3 10 30 100 300 1000 3e3 1e4];
        N = histc(S.profile_n,edges)
        bar(edges,N,'histc')
        set(gca,'xscale','log')
        
        %% make netCDF file per station: they are disconnected anayway:
        % only taken when boat does not move (unlike Ferrybox)
%         S = 
% 
%                         lon: [153590x1 double]
%                         lat: [153590x1 double]
%                           z: [153590x1 double]
%                     datenum: [153590x1 double]
%                        data: [153590x1 double]
%                       block: [153590x1 double]
%                 station_lon: [36x1 double]
%                 station_lat: [36x1 double]
%                  station_id: [153590x1 double]
%                   station_n: [36x1 double]
%             profile_datenum: [813x1 double]
%                  profile_id: [153590x1 double]
%                   profile_n: [813x1 double]        
        close all
        for ist=1:length(S.station_lon) % 36
            ind = (S.station_id==ist);
            clear P
            
            % copy all profile id for this semi-fixed positions,
            % we cannot always assume 1 profile to be instantaneous
            % as sometimes CTD is used as ferrybox/scanfish:
            % left to drift at constant z for a while
            % e.g. profile_id=311: 01-Feb-2001 08:39:42 - 01-Feb-2001 09:21:51
            % e.g. profile_id=312: 01-Feb-2001 12:45:27 - 01-Feb-2001 12:57:37
            % e.g. profile_id=313: 02-Feb-2001 05:17:02 - 02-Feb-2001 05:58:01            
            %
            % So we also have to keep all original (mostly redundant) 
            % time and place information, to see duration of extended cast
            % and boat drift (and perhaps it even had it's engine on) 
            
            P.profile_id  = unique(S.profile_id((ind)));
            nt = length(P.profile_id);
            P.profile_n       = zeros(nt,1);
            P.profile_lon     = zeros(nt,1);
            P.profile_lat     = zeros(nt,1);
            P.profile_datenum = zeros(nt,1);
            
            for it=1:nt 
                ind1 = find(S.profile_id==P.profile_id(it));
                P.profile_n  (it)     = length(ind1);
                P.profile_lon(it)     = mean(S.lon(ind1));
                P.profile_lat(it)     = mean(S.lat(ind1));
                P.profile_datenum(it) = mean(S.datenum(ind1));
            end
            
            % copy all profiles at one location into 2D [z x t] array
            %  = ragged reshape
            nz = max(P.profile_n);
            flds2copy = {'lon','lat','z','datenum','data','block'};
            for ifld = 1:length(flds2copy)
              fld = flds2copy{ifld};
              P.(fld) = nan(nz,nt);   
            end            
            for it=1:nt
              ind1 = find(S.profile_id==P.profile_id(it));
              nz1 = length(ind1);
              for ifld = 1:length(flds2copy)
                fld = flds2copy{ifld};
                P.(fld)(1:nz1,it) = S.(fld)(ind1);
              end
            end
            
            ncwritetutorial_trajectory	
            
            if OPT.plot
                [tt,zz] = meshgrid(1:nt,1:nz);

                setfig2screensize
                subplot(2,2,1)
                for ip=1:length(P.profile_id)
                plot(P.z(:,ip),zz(:,ip),'k.-','markersize',5);   
                hold on
                end
                set(gca,'YDir','reverse')
                xlabel('value of z [cm]')
                ylabel('netCDF ragged array index [#]')
                grid on
                title({[num2str(ist),' (n=',num2str(S.station_n(ist)),') :'],...
                       donar.num2strll(S.station_lat(ist),S.station_lon(ist))})

                subplot(2,2,3)
                for ip=1:length(P.profile_id)
                plot(P.z(:,ip),P.z(:,ip),'k.-','markersize',5);   
                hold on
                end
                set(gca,'YDir','reverse')
                ylabel('z [cm]')
                grid on

                subplot(2,2,2)
                if ip > 1
                pcolorcorcen(tt,zz,P.z);
                hold on
                else
                scatter     (tt(:),zz(:),10,P.z(:),'filled');
                hold on
                end
                set(gca,'Color',[.8 .8 .8])
                plot(tt,zz,'k.','markersize',4); 
                set(gca,'YDir','reverse')
                xlabel('index of profile [#]')
                ylabel('netCDF ragged array index [#]')
                [ax,~]=colorbarwithvtext('z [cm]');
                set(ax,'YDir','reverse')
                grid on

                subplot(2,2,4)
                if ip > 1
                pcolorcorcen(P.datenum,P.z,P.z);
                hold on
                else
                scatter     (P.datenum(:),P.z(:),10,P.z(:),'filled');
                hold on
                end
                plot(P.datenum,P.z,'k.','markersize',4); 
                set(gca,'YDir','reverse')
                datetick('x')
                xlabel('time');
                ylabel('z [cm]')
                [ax,~]=colorbarwithvtext('z [cm]');
                set(ax,'YDir','reverse')
                grid on

                print2a4(strrep(diafile,'.dia',['_',M.data.WNS,'_ctd_',num2str(ist),'.png']),'v','t')
                %pausedisp
                close
            end
            
        end
        %%
        close
        
        if type(ifile)==1
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
            print2a4(strrep(diafile,'.dia',['_',M.data.WNS,'_ctd.png']))
        elseif type(ifile)==2
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
