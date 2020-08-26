function theta = theta_from_t(s,t,p,pr)

%%   potential temperature from in-situ temperature, as in 
%%   Jackett, McDougall, Feistel, Wright and Griffies (2004), submitted JAOT 
%%
%%   usage        : theta = theta_from_t(s,t,p,pr)
%%
%%   s            : salinity                           (psu)
%%   t            : in-situ temperature                (deg C, ITS-90)
%%   p            : gauge pressure                     (dbar)
%%                  (absolute pressure - 10.1325 dbar)
%%   pr           : reference pressure                 (dbar)
%%
%%   theta        : potential temperature              (deg C, ITS-90)
%%
%%   calls        : de_dt_F, entropy_diff_F and zcheck
%%
%%   check value  : theta_from_t(35,20,4000,0) = 19.2110837430164
%%                                                        with nloops=1
%%                  theta_from_t(35,20,4000,0) = 19.2110837430117
%%                                                        with nloops=2

%%   DRJ on 03/06/05


zcheck(s,t,p,pr)


theta = t+(p-pr).*( 8.65483913395442d-6  - ...
               s *  1.41636299744881d-6  - ...
          (p+pr) *  7.38286467135737d-9  + ...
               t.*(-8.38241357039698d-6  + ...
               s *  2.83933368585534d-8  + ...
               t *  1.77803965218656d-8  + ...
          (p+pr) *  1.71155619208233d-10));

de_dt = 13.6;

nloops = 2;             % default

%%    NOTE: nloops = 1 gives theta with a maximum error of 5.5x10^-06
%%          nloops = 2 gives theta with a maximum error of 2.8x10^-14

n = 1; 

while n<=nloops
    n = n+1; theta_old = theta;
    dentropy = entropy_diff_F(s,t,p,theta,pr);
    theta = theta - dentropy./de_dt;
    theta = 0.5d0*(theta+theta_old); 
    de_dt = de_dt_F(s,theta,pr);
    theta = theta_old - dentropy./de_dt;   
end


return
