function Hs=S2Hs(S,f,d)


df=min(diff(f));
dd=min(diff(d));
Hs=4*sqrt(sum(sum(S))*dd*df);