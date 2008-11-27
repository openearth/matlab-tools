D = donar_read('id44-K13APFM-1998.txt')
plot(D.data.datenum,D.data.waarde)

year = 1998;

xticks = datenum(year,[1:1:13],1); % define time axis
xlim([min(xticks) max(xticks)]);
xlabel(num2str(year))
set(gca,'xtick'     ,xticks)
set(gca,'xticklabel',datestr(xticks,'mmm'))

grid on

ylabel([D.data.waarnemingssoort,' [',D.data.units,']'])