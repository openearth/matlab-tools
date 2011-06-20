function hm=InitializeModel(hm,i)

hm.Models(i).NrStations=0;
hm.Models(i).Abbr='';
hm.Models(i).Runid='';
hm.Models(i).Location=[0 0];
hm.Models(i).Continent='northamerica';
hm.Models(i).Size=1;
hm.Models(i).MapSize=[0 0];
hm.Models(i).PixLoc=[0 0];
hm.Models(i).XLim=[0 0];
hm.Models(i).YLim=[0 0];
hm.Models(i).Priority=1;
hm.Models(i).NestModel=[];
hm.Models(i).Nested=0;                
hm.Models(i).SpinUp=2;
hm.Models(i).RunTime=48;
hm.Models(i).TimeStep=5;
hm.Models(i).MapTimeStep=360;
hm.Models(i).HisTimeStep=10;
hm.Models(i).ComTimeStep=0;
hm.Models(i).NrStations=0;

