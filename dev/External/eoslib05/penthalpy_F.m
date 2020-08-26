function penthalpy = penthalpy_F(s,th)

%%   potential enthalpy from differentiating the Gibbs potential in
%%   Feistel (2003), Prog. Ocean. 58, 43-114
%%
%%   usage        : penthalpy = penthalpy_F(s,th)
%%
%%   s            : salinity               (psu)
%%   th           : potential temperature  (deg C, ITS-90)
%%
%%   penthalpy    : potential enthalpy     (J/kg)
%%
%%   calls        : zcheck
%%
%%   check value  : penthalpy_F(20,20) = 81649.48765464481

%%   DRJ on 10/12/03


zcheck(s,th)


x2 = 2.5d-2*s; x = sqrt(x2); y = 2.5d-2*th;

penthalpy = 61.013624165232955 + y.*(168776.46138048015 + ...
                 y.*(-2735.2785605119643 + y.*(2574.2164453821442 + ...
                   y.*(-1536.6644434977545 + y.*(545.734049793163 + ...
              (-50.910917284743334 - 18.30489878927802*y).*y))))) + ...
                  x2.*(416.31512917743896 + x.*(937.9793807560891 + ...
                   x.*(-3140.435779506947 + x.*(2975.170149976973 + ...
                  x.*(-1760.137081144729 + x*414.5655751783703))) + ...
                   y.*(2167.72082596016 + y.*(-1224.5772800562902 + ...
                   y.*(326.3074029273967 + 50.6703824689518*y)))) + ...
                    y.*(-12694.10018182362 + y.*(4405.71847182968 + ...
                 y.*(-2132.9690185026416 + y.*(303.91071982808035 + ...
                                            69.74975368852*y)))));


return