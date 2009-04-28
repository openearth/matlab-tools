%ODVTEST   script to test ODVRREAD and ODVDISP
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: ODVDISP

OPT.directory = 'F:\checkouts\OpenEarthTools\matlab\applications\OceanDataView\usergd30d98-data_centre630-260409_result\';
OPT.mask      = '*.txt';
OPT.files     = dir([OPT.directory,filesep,OPT.mask])

for ifile=1:length(OPT.files)

    OPT.filename = OPT.files(ifile).name;

    D = odvread([OPT.directory,filesep,OPT.filename]);
    
    odvdisp(D)
    
    clf
    subplot(1,3,1)
       index.x = 12;
       index.y = 10;
       plot  (str2num(char(D.rawdata{index.x,:})),...
              str2num(char(D.rawdata{index.y,:})))
       set   (gca,'ydir','reverse')
       xlabel(D.variables{index.x})
       ylabel(D.variables{index.y})
       grid on
       title (['Cruise: ',D.data.cruise{1}])
    
    subplot(1,3,2)
       index.x = 14;
       index.y = 10;
       plot  (str2num(char(D.rawdata{index.x,:})),...
              str2num(char(D.rawdata{index.y,:})))
       set   (gca,'ydir','reverse')
       xlabel(D.variables{index.x})
       set   (gca,'yticklabel',{})
       grid on
       title (['Station: ',mktex(D.data.station{1}),' (',num2str(D.data.lat(1)),'\circE, ',num2str(D.data.lon(1)),'\circN)'])
       
    subplot(1,3,3)
       index.x = 16;
       index.y = 10;
       plot  (str2num(char(D.rawdata{index.x,:})),...
              str2num(char(D.rawdata{index.y,:})))
       set   (gca,'ydir','reverse')
       xlabel(D.variables{index.x})
       set   (gca,'yticklabel',{})
       grid on
       title ([datestr(D.data.datenum(1),31)])  
       
       pausedisp
       
end % ifile       