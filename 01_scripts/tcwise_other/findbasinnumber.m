function ii=findbasinnumber(basinid)
% Find basin number in NC file

switch basinid
    case{'NA','North Atlantic'} 
        ii=0;                  
    case{'SA','South Atlantic'}
        ii=1;
    case{'WP','West Pacific'}
        ii=2;
    case{'EP','East Pacific'}
        ii=3;
    case{'SP','South Pacific'}
        ii=4;
    case{'NI','North Indian'}
        ii=5;
    case{'SI','South Indian'}
        ii=6;
    case{'AS','Arabian Sea'}
        ii=7;
    case{'BB','Bay of Bengal'}
        ii=8;
    case{'EA','Eastern Australia'}
        ii=9;
    case{'WA','Western Australia'}
        ii=10;
    case{'CP','Central Pacific'}
        ii=11;
    case{'CS','Carribbean Sea'}
        ii=12;
    case{'GM','Gulf of Mexico'}
        ii=13;
    case{'MM','Missing'}
        ii=14;
end
