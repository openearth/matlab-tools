function mainang=S2mainang(S,f,d)

aa=sum(S,1);
mainang=d(aa==max(aa));
