function windData=ddb_getNOAAWindData(stationId,startDate,numOfDays,outputFile);

% download data:
% step 1: find selected stationId and time period
% step 2: create string ['@' stationId]
% step 3: create url link with above string as stationID

[fPat,fName,fExt]=fileparts(outputFile);
if isempty(fExt)
    fExt='.txt.';
end
if isempty(fPat)
    fPat=pwd;
end
name=[fPat filesep fName fExt];
windData=[];

hW = waitbar(0,'Please wait...');

for ii=1:numOfDays
    currentDate=startDate+ii-1;
    data=ddb_getTableFromWeb(['http://data.nssl.noaa.gov/dataselect/nssl_result.php?datatype=sf&sdate=' D3DTimeString(currentDate,29) '&hour=00&hour2=23&outputtype=list&param_val=SPED;DRCT;PMSL&area=@' stationId],2);
    if ~isempty(data)&size(data,1)~=1
        speed=str2num(char(data(2:end,3)));
        dirs=str2num(char(data(2:end,4)));
        pres=str2num(char(data(2:end,5)));
        speed(speed==-9999.00)=nan;
        dirs(dirs==-9999.00)=nan;
        pres(pres==-9999.00)=nan;
        dates=char(data{2:end,2});
        yy=1900+str2num(dates(:,1:2));
        yy(yy<1950)=yy(yy<1950)+100;
        mm=str2num(dates(:,3:4));
        dd=str2num(dates(:,5:6));
        HH=str2num(dates(:,8:9));
        MM=str2num(dates(:,10:11));
        SS=zeros(size(MM));
        datNums=datenum(yy,mm,dd,HH,MM,SS);
        windData=[windData; datNums speed dirs pres];
        dates=strrep(cellstr(D3DTimeString(datNums,30)),'T','   ');
        dates=str2num(strvcat(dates{:}));
        fid=fopen(name,'a');
        fprintf(fid,'%8.8i   %6.6i   %4.1f   %3.1f   %6.2f\n',[dates(:,1), dates(:,2), [speed dirs pres]]');
        fclose(fid);
    end
    waitbar(ii/numOfDays,hW);
end

close(hW);
