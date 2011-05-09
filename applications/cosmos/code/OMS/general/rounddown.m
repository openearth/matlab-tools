function val=rounddown(a,d)

n=floor((a-floor(a))/d);
val=floor(a)+n*d;

