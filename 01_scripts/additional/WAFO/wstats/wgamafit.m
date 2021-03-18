function l=wgamafit(a,A,G)
%WGAMAFIT Is an internal routine for wgamfit
%


h=10^(-5);

l=log(a)-(gammaln(a+h)-gammaln(a))/h-log(A/G);
