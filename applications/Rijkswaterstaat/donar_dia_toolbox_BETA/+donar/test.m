%% Test for donar toolbox with novel data from from Rijkswaterstaat ship Zirfaea
%  * CTD(station,z,t) 1D profiles
%  * FerryBox(x,y,t) 2D trajectory (fixed z)
%  * MeetVis(x,y,z,t) 3D trajectory (undulating)
%  requested at helpdeskwater.nl
%
%See also: rws_waterbase

clc;clear all;fclose all;

basedir = 'D:\P\1209005-eutrotracks';

OPT.scan = 0; % otherwise cache is loaded
OPT.read = 1;
OPT.plot = 1;
diafiles = {'\raw\ferry_2005_-_2012_shortened.dia'};
diafiles = {'raw\CTD\raw\ctd_1998_-_1999.dia',...        %  40 s,  50 Mb, 3562 blocks
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
            
type = [1 1 1 1   2 2   3 3 3 3]; % 1=profiles, 2=2Dtrajectory, 3=3Dtrajectoy

if OPT.plot
E = nc2struct('D:\opendap.deltares.nl\thredds\dodsC\opendap\rijksoverheid\eez\Exclusieve_Economische_Zone_maart2012.nc')
L = nc2struct('D:\opendap.deltares.nl\thredds\dodsC\opendap\deltares\landboundaries\northsea.nc')
end

tic
for ifile = 5 %1:length(diafiles);
    
  disp(['File: ',num2str(ifile)])

  diafile = [basedir,filesep,diafiles{ifile}];
  File    = donar.open(diafile)

  if OPT.read
     ncolumn = 6;
     for ivar = 1:length(File.Variables);
    
        [D,M] = donar.read(File,ivar,ncolumn);

        if OPT.plot
        close all
        scatter(D(:,1),D(:,2),40,D(:,ncolumn),'.')
        hold on
        plot(L.lon,L.lat,'-' ,'color',[0 0 0])
        plot(E.lon,E.lat,'--','color',[0 0 0])
        colorbarwithvtext([M.long_name,'[',M.units,']'])
        grid on
        axis([-2 9 50 57])    
        axislat
        title(mktex(diafiles{ifile}))
        print2a4(strrep(diafile,'.dia',['_',M.WNS,'.png']),'v','w')
        end
        
     end % ivar
     
  end % read
  
end % diafiles    
