function dg=dms2deg(dms)

if dms>=0
    degrees=floor(dms);
else
    degrees=ceil(dms);
end    
rest=dms-degrees;
str=num2str(abs(rest),'%12.6f');
mins=str2num(str(3:4));
secs=0.01*str2num(str(5:end));
if dms>=0
    dg=degrees+mins/60+secs/3600;
else
    dg=degrees-mins/60-secs/3600;
end    
