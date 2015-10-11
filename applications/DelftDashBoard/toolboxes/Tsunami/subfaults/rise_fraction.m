function [ rf ] = rise_fraction(t, t0, t_rise, t_rise_ending)
% rise_fraction
% For specifying dynamic fault rupture.  Subfault files often contain these
% parameters for each subfault for an earthquake event.

% A continuously differentiable piecewise quadratic function of t that is
%   0 for t <= t0,
%   1 for t >= t0 + t_rise + t_rise_ending
% Maximum slope is at t0 + t_rise.
% t can be a scalar or an array of times and the returned result will have
% the same type.  


t1 = t0 + t_rise;
t2 = t1 + t_rise_ending;

rf = ones(size(t)).*(t>t0);

if t2 ~= t0
    t20 = t2-t0;
    t10 = t1-t0;
    t21 = t2-t1;
    
    c1 = t21 ./ (t20.*t10.*t21);
    c2 = t10 ./ (t20.*t10.*t21);
    
    [row,col] = find(t>t0 & t<=t1);
    for idx = 1:numel(col)
        rf(col(idx)) = (c1.*(t(col(idx))-t0).^2);
    end
    
    [row,col] = find(t>t1 & t<=t2);
    for idx = 1:numel(col)
        rf(col(idx)) = (1.-(c2.*(t(col(idx))-t2).^2));
     end

end

