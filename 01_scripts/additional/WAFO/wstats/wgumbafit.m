function l=wgumbafit(a,data)
%WGUMBAFIT Is an internal routine for wgumbfit
%

l=a-mean(data)+mean(data.*exp(-data/a))/mean(exp(-data/a));
