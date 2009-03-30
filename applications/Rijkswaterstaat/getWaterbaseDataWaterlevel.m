%GETWATERBASEDATALOOP   example script to download waterbase data in loop
%
% See also: GETWATERBASEDATA, DONAR_READ, <a href="http://www.waterbase.nl">www.waterbase.nl</a>,  
%           GETWATERBASEDATA_SUBSTANCES, GETWATERBASEDATA_LOCATIONS

% 
% CodeName :54%7CWaterhoogte+in+cm+t.o.v.+mean+sea+level+in+oppervlaktewater"
% FullName :Waterhoogte in cm t.o.v. mean sea level in oppervlaktewater
% Code     :54
% indSub   :653
% 

OPT.Code   = 54;

%% Match and check Substance
% --------------------------------

   SUB        = getWaterbaseData_substances;
   OPT.indSub = find(SUB.Code==OPT.Code);

   disp(['--------------------------------------------'])
   disp(['indSub   :',num2str(             OPT.indSub )])
   disp(['CodeName :',        SUB.CodeName{OPT.indSub} ])
   disp(['FullName :',        SUB.FullName{OPT.indSub} ])
   disp(['Code     :',num2str(SUB.Code    (OPT.indSub))])

%% get and check Locations
% --------------------------------

   LOC = getWaterbaseData_locations(SUB.Code(OPT.indSub));

   for indLoc=1:length(LOC.ID)
   
      disp(['----------------------------------------'])
      disp(['indLoc   :',num2str(             indLoc ),' of ',num2str(length(LOC.ID))])
      disp(['FullName :',        LOC.FullName{indLoc} ])
      disp(['ID       :',        LOC.ID{indLoc} ])
      
      getWaterbaseData(SUB.Code(OPT.indSub),LOC.ID{indLoc},datenum([1961 2008],1,1),...
                      'F:\checkouts\OpenEarthRawData\rijkswaterstaat\waterbase\raw\')   
   end
   
% AUKFPFM     Aukfield platform          
% EIELSGT     Eierlandse Gat             
% EURPFM      Euro platform              
% HARVMD      Haringvlietmond            
% IJMDMNTSPS  IJmuiden munitiestortplaats
% K13APFM     K13a platform              
% LICHTELGRE  Lichteiland Goeree         
% NOORDWMPT   Noordwijk meetpost         
% SANDTE      Sandettie                  
% SCHIERMNOND Schiermonnikoog noord      
% SCHOUWBK    Schouwenbank  

   