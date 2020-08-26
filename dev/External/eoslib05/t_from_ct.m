function t = t_from_ct(s,ct,p)

%%   in-situ temperature from conservative temperature
%%   Jackett, McDougall, Feistel, Wright and Griffies (2004), submitted JAOT
%%
%%   usage        : t = t_from_ct(s,ct,p)
%%
%%   s            : salinity                           (psu)
%%   ct           : conservative temperature           (deg C, ITS-90)
%%   p            : gauge pressure                     (dbar)
%%                  (absolute pressure - 10.1325 dbar)
%%
%%   t            : in-situ temperature                (deg C, ITS-90)
%%
%%   calls        : theta_from_ct, theta_from_t and zcheck
%%
%%   check value  : t_from_ct(20,20,1000) = 19.7267162422026
%%                                              with 1 loop in theta_from_ct
%%                  t_from_ct(20,20,1000) = 19.726716277357
%%                                              with 2 loops in theta_from_ct

%%   DRJ on 11/12/03


zcheck(s,ct,p)


pr0 = zeros(size(s)); 

theta = theta_from_ct(s,ct);


t = theta_from_t(s,theta,pr0,p);


return
