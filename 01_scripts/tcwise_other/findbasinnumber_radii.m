function ii=findbasinnumber_radii(basinid)
% Find basin number for wind radii

switch basinid
    case{'NA','North Atlantic'} 
        ii=6;                  
    case{'SA','South Atlantic'}
        ii=7;
    case{'WP','West Pacific'}
        ii=4;
    case{'EP','East Pacific'}
        ii=5;
    case{'SP','South Pacific'}
        ii=3;
    case{'NI','North Indian'}
        ii=0;
    case{'SI','South Indian'}
        ii=3;
    case{'AS','Arabian Sea'}
        ii=0;
    case{'BB','Bay of Bengal'}
        ii=0;
    case{'EA','Eastern Australia'}
        ii=2;
    case{'WA','Western Australia'}
        ii=2;
    case{'CP','Central Pacific'}
        ii=7;
    case{'CS','Carribbean Sea'}
        ii=6;
    case{'GM','Gulf of Mexico'}
        ii=6;
    case{'MM','Missing'}
        ii=7;
end
