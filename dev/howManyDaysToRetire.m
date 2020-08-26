function nrDays = howManyDaysToRetire(birthDate,sctOpt)
% calculates how many days you still have to work until you retire%
% INPUT

% limitations:
% does not take into account future changes in the law
% does not take into accout oude lullendagen (what is it in english, does
% it exist in Belgium)?
% does not into account parental leave, tijdskrediet etc
% does not take into accounmt parttime work
% does not take into account changes in the amount of free days because of
% parental/leave, first year at works etc
% does not take into account the exact date of legal hollidays in the year
% you retire. Instead they are applied pro rata.

%optional settings
if nargin==1
    sctOpt= struct;
end
sctOpt  = Util.setDefault(sctOpt,'holidayPerYear',32);
sctOpt  = Util.setDefault(sctOpt,'legalHolidayPerYear',10);
sctOpt  = Util.setDefault(sctOpt,'retireAge',67);
sctOpt  = Util.setDefault(sctOpt,'holidaysLeftThisYear',0);

% not needed; in case I implenmten the rulses for the age when you retire
age = floor((now-birthDate)/365.2425);

birthVec      = datevec(birthDate);
retireDate    = birthVec;
retireDate(1) = retireDate(1)+sctOpt.retireAge;

% round to first day of next month(  :-(
if  retireDate(3) ~=1
    retireDate(3) = 1;
    retireDate(2) = retireDate(2)+1;
end
nowVec = datevec(now);
nrYears = max((retireDate(1)-1)-(nowVec(1)+1),0);

retireYear = datenum([retireDate(1) 1 1]);
retireDate = datenum(retireDate);

% delete weekend
allDays = floor(now):retireDate;
weekend = weekday(allDays)== 1 | weekday(allDays)== 7;
nrDays = sum(~weekend);

% delete holidays
nrDays  = nrDays - nrYears*(sctOpt.legalHolidayPerYear+sctOpt.holidayPerYear);
nDayLastYear = (retireDate-retireYear-1)/365;
nrDays  = nrDays - floor(nDayLastYear.*sctOpt.legalHolidayPerYear+sctOpt.holidayPerYear);







