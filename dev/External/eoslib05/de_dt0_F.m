function de_dt = de_dt0_F(s,th)

%%   d(entropy)/dt from twice differentiating the Gibbs potential in
%%   Feistel (2003), Prog. Ocean. 58, 43-114
%%
%%   usage        : de_dt = de_dt0_F(s,th)
%%
%%   s            : salinity                           (psu)
%%   th           : potential temperature              (deg C, ITS-90)
%%
%%   de_dt        : d(entropy)/dt                      (kJ/kgK^2)
%%
%%   calls        : zcheck
%%
%%   check value  : de_dt0_F(35,20) = 13.6325636921387

%%   DRJ on 12/10/03


zcheck(s,th)

x2 = 2.5d-2*s; x = sqrt(x2); y = 2.5d-2*th;

de_dt = 24715.571866078 + x2.*(-1858.920033948178 + ...
                     x.*(317.440355256842 + y.*(-405.1392883572282 + ...
                     202.6815298758072*y)) + y.*(1562.563716288858 + ...
                     y.*(-1165.8752731900836 + 348.7487684426*y))) + ...
                   y.*(-4420.4472249096725 + y.*(1778.231237203896 + ...
                       y.*(-1160.5182516851419 + (569.531539542516 - ...
                                       128.13429152494615*y).*y)));


de_dt = 6.25d-4*de_dt;


return
