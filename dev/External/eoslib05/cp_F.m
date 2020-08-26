function cp = cp_F(s,t,p)

%%   heat capacity (specific heat) from d(entropy)/dt, as in
%%   Feistel (2003), Prog. Ocean. 58, 43-114
%%
%%   usage        : cp = cp_F(s,t,p)
%%
%%   s            : salinity                           (psu)
%%   t            : in-situ temperature                (deg C, ITS-90)
%%   p            : gauge pressure                     (dbar)
%%                  (absolute pressure - 10.1325 dbar)
%%
%%   cp           : heat capacity                      (J/kgK)
%%
%%   calls        : de_dt_F and zcheck
%%
%%   check value  : cp_F(20,20,1000) = 4047.39013136857

%%   DRJ on 11/12/03


zcheck(s,t,p);


cp = (t+273.15).*de_dt_F(s,t,p);


return
