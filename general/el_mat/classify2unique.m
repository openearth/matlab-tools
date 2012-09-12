function [c,v] = classify2unique(x) 
%CLASSIFY2UNIQUE  make matrix with indexes into vector with unique values
%
% [C,V] = classify2unique(X) where X is a matrix, C is
% an integer matrix with 1-based matlab pointers into vector 
% V that contains the unique values of X such that
% X(X==V(i))==V(i) for i=1:length(V). NaN values in X get index 0. 
%
% Example: plotting fields of unique datenum values
% as returned by nc_cf_gridset_getData:
%
%   [x,y,z]=peaks;
%   [t,v] = classify2unique(roundoff(z,0)+now);
%   nv = length(v);
%   pcolor(x,y,t)
%
%   caxis   ([0.5 nv+0.5])
%   colormap(jet(nv));
%   [ax,c1] =  colorbarwithtitle('',1:nv+1);
%   set(ax,'yticklabel',datestr(v,29))
%
%See also: unique, hist

   v  = unique(x(find(~isnan(x))));
   nv = length(v);

   c = repmat(0,size(x));
   for iv=1:nv
       mask = (x==v(iv));
       c(mask)=iv;
   end
