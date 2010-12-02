function tp=S2tp(S,f,d)

aa=sum(S,2);
tp=f(aa==max(aa));
tp=1/tp;