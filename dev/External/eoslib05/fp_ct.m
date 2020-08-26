function tf = fp_ct(s,p,sat)

%%   conservative temperature freezing point of seawater, as in
%%   Jackett, McDougall, Feistel, Wright and Griffies (2004), submitted JAOT
%%
%%   usage        : tf = fp_ct(s,p,{sat})
%%
%%   s            : salinity                                (psu)
%%   p            : gauge pressure                          (dbar)
%%                  (absolute pressure - 10.1325 dbar)
%%   sat          : (optional) string variable
%%                   'air-sat'  - air saturated water       (default)
%%                   'air-free' - air free water
%%
%%   tf           : conservative freezing temperature       (deg C, ITS-90)
%%
%%   calls        : zcheck
%%
%%   check value  : fp_ct(35,200,'air-sat')   = -2.073223432555101 deg C
%%                  fp_ct(35,200,'air-free') = -2.071222603621528 deg C

%%   DRJ on 12/12/03


zcheck(s,p)


if nargin==2, sat = 'air-sat'; end

sqrts = sqrt(s); 

tf_num =                 1.7945004324529630d-02    + ...
                    s.*(-5.8403584591688665d-02    + ...
                sqrts.*( 2.4573268704237757d-03    - ...
                sqrts *  3.4327919114658586d-04))  + ...
                    p.*(-7.3981255037990307d-04    + ...
                    p.*(-7.3845034467503930d-09    + ...
                    s *  1.9069793902937708d-11));

tf_den =                 1.0000000000000000d+00    + ...
                    p.*(-1.7509421027054954d-05    + ...
                    p *  5.2153095812720787d-10)   + ...
          s.*s.*sqrts.*  1.4719680395528758d-06; 


tf = tf_num ./ tf_den;


if strcmp(sat,'air-sat')  
    tf = tf             -2.661425530980574d-03     + ...
                    s *  1.887418849738127d-05;
elseif strcmp(sat,'air-free')  
    
else 
    error('***   Error in fp_ct.m: invalid third argument   ***')
end


return
