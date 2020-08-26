function ct = ct_from_t(s,t,p)

%%   conservative temperature from in-situ temperature, as in
%%   Jackett, McDougall, Feistel, Wright and Griffies (2004), submitted JAOT
%%
%%   usage        : ct = ct_from_t(s,t,p)
%%
%%   s            : salinity                           (psu)
%%   t            : in-situ temperature                (deg C, ITS-90)
%%   p            : gauge pressure                     (dbar)
%%                  (absolute pressure - 10.1325 dbar)
%%
%%   ct           : conservative temperature           (deg C, ITS-90) 
%%
%%   calls        : ct_from_theta, theta_from_t and zcheck
%%
%%   check value  : ct_from_t(20,20,1000) = 20.276902067802

%%   DRJ on 10/12/03


zcheck(s,t,p)


pr0 = zeros(size(s));

theta = theta_from_t(s,t,p,pr0);


ct = ct_from_theta(s,theta);


return
