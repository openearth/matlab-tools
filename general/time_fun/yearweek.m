function w = yearweek(datenums);
%YEARWEEK   Returns weeknumber using datenumber.
%
% w = yearweek(datenum) returns
% the week number assuming januari 1st to 7th
% as the first week.
%
% So this is not the week as applied in agenda's.

doy     = yearday(datenums);

w       = divcount(doy,7);
