function OK = iso2datenum_test
%ISO2DATENUM_TEST   unit test for iso2datenum
%
%See also: iso2datenum

%% check timezones

   tzhr  = [-24:24];
   tzstr = [];
   
   OK = 1;
   for i=1:length(tzhr)
   
      [dummy,tzstr{i}]=iso2datenum(['1999-1-14 13:12:11 ',num2str(tzhr(i),'%0.2d'),':00']);
      OK = OK&strcmpi(strtrim(tzstr{i}),[num2str(tzhr(i),'%0.2d'),':00']);
   
   end

%% check dates

   OK(end+1)=datenum(1999, 1,14,13,12,11.0)==iso2datenum('1999-1-14 13:12:11 +01:00');
   OK(end+1)=datenum(1999, 1,14,13,12,11.0)==iso2datenum('1999-1-14T13:12:11 +01:00');
   	      	 
   OK(end+1)=datenum(1999, 1,14,13,12,11.0)==iso2datenum('1999-1-14 13:12:11Z');
   OK(end+1)=datenum(1999, 1,14,13,12,11.0)==iso2datenum('1999-1-14T13:12:11Z');
   	      	 
   OK(end+1)=datenum(1999, 1,14,13,12,11.0)==iso2datenum('1999-1-14 13:12:11');
   OK(end+1)=datenum(1999, 1,14,13,12,11.0)==iso2datenum('1999-1-14T13:12:11');
   	      	 
   OK(end+1)=datenum(1999, 1,14,13,12,11.5)==iso2datenum('1999-1-14 13:12:11.5');
   OK(end+1)=datenum(1999, 1,14,13,12,11.5)==iso2datenum('1999-1-14T13:12:11.5');
   
   OK(end+1)=datenum(1999, 1,14, 0, 0, 0.0)==iso2datenum('1999-1-14');
   OK(end+1)=datenum(1999, 1, 0, 0, 0, 0.0)==iso2datenum('1999-1');
   OK(end+1)=datenum(1999, 0, 0, 0, 0, 0.0)==iso2datenum('1999');
   
   OK = all(OK);


% NOTE:
%
%  >> datenum(1900,0,0) = 693961
%  >> datenum(1900,1,0) = 693961
%        
%  >> datenum(1900,0,1) = 693962
%  >> datenum(1900,1,1) = 693962
%  
