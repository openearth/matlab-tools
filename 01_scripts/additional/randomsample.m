function [y,ix]=randomsample(x,k)
n=length(x);
ix=floor(n*rand(1,k))+1;
y=x(ix);
