function ct = ct_from_theta(s,theta)

%%   conservative temperature from potential temperature, as in
%%   Jackett, McDougall, Feistel, Wright and Griffies (2004), submitted JAOT
%%
%%   usage        : ct = ct_from_theta(s,theta)
%%
%%   s            : salinity                  (psu)
%%   theta        : potential temperature     (deg C, ITS-90)
%%
%%   ct           : conservative temperature  (deg C, ITS-90) 
%%
%%   calls        : penthalpy_F and zcheck
%%
%%   check value  : ct_from_theta(20,20) = 20.45274961282756

%%   DRJ on 10/12/03


zcheck(s,theta)


rec_Cp0 = 2.50494524832013d-4; % Cp0 = 3992.10322329649;


ct = rec_Cp0*penthalpy_F(s,theta);


return