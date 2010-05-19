function windData=ddb_getOnlineWindDataEngine(stationID,startDate,numberOfDays,outputFile,condOutput)

[fPat,fName,fExt]=fileparts(outputFile);
if isempty(fExt)
    fExt='.txt.';
end
if isempty(fPat)
    fPat=pwd;
end
name=[fPat filesep fName fExt];
windData=[];

h = waitbar(0,'Please wait...');

for ii=1:numberOfDays

    currentDate=startDate+ii-1;

    [s status]=urlread(['http://www.weatherunderground.com/history' stationID D3DTimeString(currentDate,10)...
        '/' D3DTimeString(currentDate,5) '/' D3DTimeString(currentDate,7) '/DailyHistory.html?req_city=NA&req_state=NA&req_statename=NA&format=1']);

    if status==0
        tic
        g=warndlg({'The connection is lost, trying to reconnect in 30 seconds... ',['times ' num2str(round(toc)) ' seconds']},'Online source not available');
        while status==0&toc<30
            [s status]=urlread(['http://www.weatherunderground.com/history' stationID D3DTimeString(currentDate,10)...
                '/' D3DTimeString(currentDate,5) '/' D3DTimeString(currentDate,7) '/DailyHistory.html?req_city=NA&req_state=NA&req_statename=NA&format=1']);
        end
        close(g)
        if status==0
            warndlg('www.WeatherUnderground.com may be offline or you are not connected to the internet','Online source not available');
            close(h)
            return
        end
    end

    if findstr(s,'Km/h')
        units='metric'
    elseif findstr(s,'MPH')
        units='english'
    else
      units=(char(questdlg('Units on weatherunderground cannot be detected, please specify:','Which units?','metric','english','metric')));
    end  


    [a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12]=strread(s,'%s%s%s%s%s%s%s%s%s%s%s%s','delimiter',',','headerlines',2);%,'whitespace','VariableCalm');

    a8=strrep(a8,'Calm','0'); % wind is vrij zwak, dus deze stellen we gelijk aan 0
    a8=strrep(a8,'N/A','-999'); % wind is n/a, dus moet nan worden
    a8=strrep(a8,'-9999.0','-999'); %wind is -9999 dus moet nan worden
    a7=strrep(a7,'Calm','-999'); % wind is vrij zwak, dus we geven deze (nu te herkennen aan -999) verderop een nan-waarde
    a7=strrep(a7,'Variable','-999'); % wind is variabel, voor gemak geven we deze (nu te herkennen aan -999) verderop een nan-waarde
    a7=strrep(a7,'N/A','-999'); % wind is n/a, voor gemak geven we deze (nu te herkennen aan -999) verderop een nan-waarde
    a5=strrep(a5,'N/A','-999'); % air pressure is n/a, voor gemak geven we deze (nu te herkennen aan -999) verderop een nan-waarde
    a5=strrep(a5,'-9999','-999'); % air pressure is n/a, voor gemak geven we deze (nu te herkennen aan -999) verderop een nan-waarde
    a12=strrep(a12,'<br />',''); % weghalen achter description

    idd=find(strcmp(a7,''));
    for iidd=1:length(idd)-1
        a7{idd(iidd)}='-999';
    end

    % lege waarden in de druk omzetten (behalve laatste, die moet leeg
    % zijn...)
    a5(cellfun('isempty',a5))={'-999'};
    a5{length(a5)}='';

    if strcmpi(a8{1},'')==1 % check of de data niet leeg is
        a8={'-999'};
        a7={'-999'};
        a5={'-999'};
        a1={'12:00 AM'};
        a1{2}='';
    end



    % nu omzetten van windrichtingen in woorden naar graden tov N
    a7=strrep(a7,'North','0');
    a7=strrep(a7,'NNE','22.5');
    a7=strrep(a7,'ENE','67.5');
    a7=strrep(a7,'East','90');
    a7=strrep(a7,'ESE','112.5');
    a7=strrep(a7,'SSE','157.5');
    a7=strrep(a7,'South','180');
    a7=strrep(a7,'SSW','202.5');
    a7=strrep(a7,'WSW','247.5');
    a7=strrep(a7,'West','270');
    a7=strrep(a7,'WNW','292.5');
    a7=strrep(a7,'NNW','337.5');
    a7=strrep(a7,'NE','45');
    a7=strrep(a7,'SE','135');
    a7=strrep(a7,'NW','315');
    a7=strrep(a7,'SW','225');

    % datenums van tijden maken en wegzetten in matrix B
    B=datenum(char(a1(1:end-1)))-datenum('00:00')+currentDate;

    % snelheden omrekenen van mph/km/u naar m/s en wegzetten in matrix B en
    % eerst -999 vervangen door nannen
% NB: blijkbaar zijn de snelheden in de csv-files op www.wunderground.com altijd in mph gegeven, ookal doet de header anders vermoeden...

    B(:,2)=str2num(char(a8));
    B(find(B(:,2)==-999),2)=nan;
    B(:,2)=B(:,2)*0.44704; % dus altijd omrekenen van mpu naar m/s

%    switch units
%        case 'english'
%            B(:,2)=B(:,2)*0.44704;
%        case 'metric'
%            B(:,2)=B(:,2)/3.6;
%    end
    
    % windrichtingen wegzetten in matrix B en -999 vervangen door nannen
    B(:,3)=str2num(char(a7));
    B(find(B(:,3)==-999),3)=nan;

    % luchtdruk omrekenen van inch Hg naar hPa (mBar)
    B(:,4)=str2num(char(a5));
    B(find(B(:,4)==-999),4)=nan;
    switch units
        case 'english'
            B(:,4)=B(:,4).*33.83816;
        case 'metric'
    end
    B(B(:,4)>1500|B(:,4)<500,4)=nan;

    B(isnan(B(:,1)),:)=[];
    dates=strrep(cellstr(D3DTimeString(B(:,1),30)),'T','   ');
    dates=str2num(strvcat(dates{:}));

    fid=fopen(name,'a');
    if strcmp(condOutput,'No')
        fprintf(fid,'%8.8i   %6.6i   %4.1f   %3.1f   %6.2f\n',[dates(:,1), dates(:,2), B(:,2:end)]');
    else
        fprintf(fid,'%s',...
            [num2str(dates(:,1),'%8.8i') repmat(' ',length(dates(:,1)),1) num2str(dates(:,2),'%6.6i') repmat(' ',length(dates(:,1)),1)...
            num2str(B(:,2:end),'%4.1f   %3.1f   %6.2f') repmat(' ',length(dates(:,1)),1) char(a12(1:end-1)) repmat(char(13),length(dates(:,1)),1)]');
    end
    fclose(fid);
    windData=[windData;B];
    clear B

    waitbar(ii/numberOfDays,h)
end
close(h)
