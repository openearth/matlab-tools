%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%COMPUTE_DOMINANT_DISCHARGE Time-weighted dominant discharges.
% [Q_dom_slope,Q_dom_depth]=compute_dominant_discharge(time_datetime,Q,n)
%
% INPUTS
%   time_datetime        Datetime vector with at least two non-missing,
%                        strictly increasing timestamps.
%   Q                    Finite, real, nonnegative discharge vector with
%                        one value per timestamp. Row or column is accepted.
%   degree_non_linearity Positive, finite scalar exponent n.
%
% OUTPUTS
%   Q_dom_slope          Slope-related dominant discharge:
%                        <Q^(n/3)>^(3/n).
%   Q_dom_depth          Depth-related dominant discharge:
%                        <Q^n>^(1/n).
%   Both outputs are scalars in the same units as Q.
%
% METHOD
%   For any positive exponent a, the shared helper computes
%       Q_dom = (integral(Q(t)^a dt)/T)^(1/a),
%   where T is the duration from the first to the last timestamp. The
%   time average <Q^a> represents integral(p(q)*q^a dq), with p(q) the
%   discharge probability density defined by the time spent at each flow.
%   Elapsed time is converted to seconds, and trapezoidal integration
%   assumes Q^a varies linearly between observations. Unequal sampling
%   intervals are therefore weighted by duration, not by sample count.
%   All intervals are included; missing discharge values are rejected.

function [Q_dom_slope,Q_dom_depth,Q_mean]=compute_dominant_discharge(time_datetime,Q,degree_non_linearity)


if ~isa(time_datetime,'datetime') || ~isvector(time_datetime) || ...
		numel(time_datetime)<2 || any(isnat(time_datetime(:)))
	error('compute_dominant_discharge:InvalidTime', ...
		'Time must be a datetime vector with at least two non-missing samples.');
end
validateattributes(Q,{'numeric'},{'real','vector','finite','nonnegative', ...
	'numel',numel(time_datetime)},mfilename,'Q',2);
validateattributes(degree_non_linearity,{'numeric'}, ...
	{'real','scalar','finite','positive'},mfilename,'degree_non_linearity',3);

time_seconds=seconds(time_datetime(:)-time_datetime(1));
if any(diff(time_seconds)<=0)
	error('compute_dominant_discharge:NonIncreasingTime', ...
		'Time must be strictly increasing.');
end

degree_non_linearity=double(degree_non_linearity);

discharge_power=degree_non_linearity/3;
Q_dom_slope=compute_dominant_discharge_single(time_seconds,Q,discharge_power);

discharge_power=degree_non_linearity;
Q_dom_depth=compute_dominant_discharge_single(time_seconds,Q,discharge_power);

discharge_power=1;
Q_mean=compute_dominant_discharge_single(time_seconds,Q,discharge_power);

end %function

%%
%% FUNCTION
%%

function Q_dom=compute_dominant_discharge_single(time_seconds,Q,discharge_power)
Q_moment=double(Q(:)).^discharge_power;
Q_dom=(trapz(time_seconds,Q_moment)/time_seconds(end))^(1/discharge_power);
end %function