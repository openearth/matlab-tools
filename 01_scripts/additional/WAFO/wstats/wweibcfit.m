function l=wweibcfit(c,data)
%WWEIBCFIT Is an internal routine for wweibfit
%

l=1./c-sum(data.^c.*log(data))/(sum(data.^c))+sum(log(data))/size(data,1);
