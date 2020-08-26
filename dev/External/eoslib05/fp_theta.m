function tf = fp_theta(s,p,sat)

%%   potential temperature freezing point of seawater, as in
%%   Jackett, McDougall, Feistel, Wright and Griffies (2004), submitted JAOT
%%
%%   usage        : tf = fp_theta(s,p,{sat})
%%
%%   s            : salinity                                (psu)
%%   p            : gauge pressure                          (dbar)
%%                  (absolute pressure - 10.1325 dbar)
%%   sat          : (optional) string variable
%%                   'air-sat'  - air saturated water       (default)
%%                   'air-free' - air free water
%%
%%   tf           : potential freezing temperature          (deg C, ITS-90)
%%
%%   calls        : zcheck
%%
%%   check value  : fp_theta(35,200,'air-sat')   = -2.076426227617581 deg C
%%                  fp_theta(35,200,'air-free') = -2.074408175943127 deg C

%%   DRJ on 2/6/04


zcheck(s,p)


if nargin==2, sat = 'air-sat'; end

sqrts = sqrt(s); 

tf_num =                 2.5180516744541290d-03    + ...
                    s.*(-5.8545863698926184d-02    + ...
                sqrts.*( 2.2979985780124325d-03    - ...
                sqrts *  3.0086338218235500d-04))  + ...
                    p.*(-7.0023530029351803d-04    + ...
                    p.*( 8.4149607219833806d-09    + ...
                    s *  1.1845857563107403d-11));

tf_den =                 1.0000000000000000d+00    + ...
                    p.*(-3.8493266309172074d-05    + ...
                    p *  9.1686537446749641d-10)   + ...
          s.*s.*sqrts.*  1.3632481944285909d-06; 


tf = tf_num ./ tf_den;


if strcmp(sat,'air-sat')  
    tf = tf             -2.5180516744541290d-03    + ...
                    s *  1.428571428571429d-05;
elseif strcmp(sat,'air-free')  
    
else 
    error('***   Error in fp_theta.m: invalid third argument   ***')
end


return