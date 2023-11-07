
%%

fpath_knmi='c:\Users\chavarri\Downloads\etmgeg_260.txt';

[tim_dtime,rain]=read_KNMI(fpath_knmi);

%%

mean_rain=monthly_data(tim_dtime,rain);

%%
[maxv,maxi]=max(mean_rain);
year_u(maxi)
mean(mean_rain,'omitnan')
std(mean_rain,'omitnan')

%%

figure
hold on
plot(tim_dtime,rain);

%%

figure
hold on
plot(tim_oct,rain_oct);

%%

figure
hold on
bar(year_u,mean_rain)
ylabel('total rain in October [mm]')
title('De Bilt')