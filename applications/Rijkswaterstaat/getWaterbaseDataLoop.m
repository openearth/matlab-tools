%GETWATERBASEDATALOOP   example script to download waterbase data in loop
%
% See also: GETWATERBASEDATA, DONAR_READ, www.waterbase.nl,  
%           GETWATERBASEDATA_SUBSTANCES, GETWATERBASEDATA_LOCATIONS

% 
% CodeName :22%7CSignificante+golfhoogte+uit+energiespectrum+van+30-500+mhz+in+cm+in+oppervlaktewater"
% FullName :Significante golfhoogte uit energiespectrum van 30-500 mhz in cm in oppervlaktewater
% Code     :22
% indSub   :509
% 
% CodeName :
% FullName :
% Code     :24
% indSub   :
% 

OPT.Code   = 24;

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
                      'P:\z3945_Maasvlakte2\z4103-zandwin\wave\golvenSvasek\waterbase\')   
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

   