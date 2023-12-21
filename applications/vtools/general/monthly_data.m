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
%Ad-hoc function to read KNMI data. It should be read in `read_csv_data`. 

function mean_rain=monthly_data(tim_dtime,rain,month_num)

tim_month=month(tim_dtime);
bol_month=tim_month==month_num;
tim_year=year(tim_dtime);
year_u=unique(tim_year);
ny=numel(year_u);
bol_nan=isnan(rain);
mean_rain=NaN(ny,1);

for ky=1:ny
    bol_year=tim_year==year_u(ky);
    
    bol_get=bol_year & bol_month & ~bol_nan';

    days_im=caldays(caldiff(datetime(year_u(ky),month_num,1)+calmonths(1:2),'days'));
    
    rain_get=rain(bol_get);
    if sum(bol_get)~=days_im
        fprintf('days in %d is %d \n',year_u(ky),sum(bol_get));
    else
        mean_rain(ky)=sum(rain_get);
    end

end

end %function




