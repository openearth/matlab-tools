function Transform(s)

if isstr(s.StartDate)
    s.StartDate = datenum(s.StartDate,23)
    s.EndDate   = datenum(s.EndDate,23)
end

% update input files
getDONARdata;
getMATROOSdata(s);

% parameters
load('TransMatrix_InputParameters_a.mat');

%% input

% DATAFILES
% IJMUIDEN
YM6                 = textread('data_YM6a.asc','%f','headerlines',6);
YM6                 = reshape(YM6,6,length(YM6)/6)';
YM6a                = textread('data_YM6a.asc','%s','headerlines',6);
YM6a                = reshape(YM6a,6,length(YM6a)/6)';

ym6.Date            = YM6a(:,1);
ym6.Time            = YM6a(:,2);
ym6.Datenum         = datenum(strcat(ym6.Date,ym6.Time),'yyyymmddHHMMSS');
ym6.Hm0.data        = YM6(:,3);
ym6.Th0.data        = YM6(:,4);
ym6.Tm02.data       = YM6(:,5);
ym6.surge.data      = YM6(:,6);

clear YM6 YM6a

% EUROPLATFORM
EUR                 = textread('data_EURa.asc','%f','headerlines',6);
EUR                 = reshape(EUR,6,length(EUR)/6)';
EURa                = textread('data_EURa.asc','%s','headerlines',6);
EURa                = reshape(EURa,6,length(EURa)/6)';

eur.Date            = EURa(:,1);
eur.Time            = EURa(:,2);
eur.Datenum         = datenum(strcat(eur.Date,eur.Time),'yyyymmddHHMMSS');
eur.Hm0.data        = EUR(:,3);
eur.Th0.data        = EUR(:,4);
eur.Tm02.data       = EUR(:,5);
eur.surge.data      = EUR(:,6);

clear EUR EURa

% EIERLANDSE GAT
ELD                 = textread('data_ELDa.asc','%f','headerlines',6);
ELD                 = reshape(ELD,6,length(ELD)/6)';
ELDa                = textread('data_ELDa.asc','%s','headerlines',6);
ELDa                = reshape(ELDa,6,length(ELDa)/6)';

eld.Date            = ELDa(:,1);
eld.Time            = ELDa(:,2);
eld.Datenum         = datenum(strcat(eld.Date,eld.Time),'yyyymmddHHMMSS');
eld.Hm0.data        = ELD(:,3);
eld.Th0.data        = ELD(:,4);
eld.Tm02.data       = ELD(:,5);
eld.surge.data      = ELD(:,6);

clear ELD ELDa

% waveconditions from SWAN simulations
WC.eur              = Input.data(3:8:length(Input.data),:);
WC.ym6              = Input.data(4:8:length(Input.data),:);
WC.eld              = Input.data(5:8:length(Input.data),:);

% XY-coordinates (using least square technique)
aa                  = sqrt(((Grid.X - s.Loc.X).^2 + (Grid.Y - s.Loc.Y).^2));
[s.Loc.M s.Loc.N]   = find(aa==min(min(aa)));

%% convert timeseries

% if offshore direction 30 < dir < 180, then no transformation
% because these data are not classified in the matrix
nid                 = find(ym6.Th0.data >= 30 & ym6.Th0.data <= 200);
ym6.Hm0.data(nid)   = NaN;
ym6.Th0.data(nid)   = NaN;
ym6.Tm02.data(nid)  = NaN;
ym6.surge.data(nid) = NaN;
eur.Hm0.data(nid)   = NaN;
eur.Th0.data(nid)   = NaN;
eur.Tm02.data(nid)  = NaN;
eur.surge.data(nid) = NaN;
eld.Hm0.data(nid)   = NaN;
eld.Th0.data(nid)   = NaN;
eld.Tm02.data(nid)  = NaN;
eld.surge.data(nid) = NaN;

% transformation of Tm02 to Tp (because no realible results for Tm, only for Tp)
ym6.Tp              = ym6.Tm02;
ym6.Tp.data         = ym6.Tp.data * 1.28; 
eur.Tp              = eur.Tm02;
eur.Tp.data         = eur.Tp.data * 1.28; 
eld.Tp              = eld.Tm02;
eld.Tp.data         = eld.Tp.data * 1.28; 

% find right transformation factor from the matrix
% step 1: classify data
% step 2: classify SWAN runs
% step 3: find right factor
vid = find(ym6.Datenum>=s.StartDate & ym6.Datenum<s.EndDate);

hh = waitbar(0,'Transforming offshore data to nearshore, Please wait .......');
for n=1:length(vid)
    waitbar(n/length(vid),hh)
    % classify values, so that the transformation matrix can be used
    for i=1:length(classes{1})
        for j=1:length(classes{2})
            did  = find( ym6.Hm0.data(vid(n)) > classes{1}(i,1) & ...
                         ym6.Hm0.data(vid(n)) < classes{1}(i,2) & ....
                         ym6.Th0.data(vid(n)) > classes{2}(j,1) & ...
                         ym6.Th0.data(vid(n)) < classes{2}(j,2));
            if did ==1; ii=i; jj=j; else; end
        end
    end
    if exist('ii')
        if s.Loc.N < 105

            if (~isnan(ym6.Hm0.data(vid(n))) & ~isnan(WCmat(ii,jj)) & ym6.Th0.data(n)>280);
                output.Hm0.data(n)     = Trans(WCmat(ii,jj)).Hs(s.Loc.M,s.Loc.N)   * ym6.Hm0.data(vid(n));
                output.Hdir.data(n)    = Trans(WCmat(ii,jj)).Hdir(s.Loc.M,s.Loc.N) + ym6.Th0.data(vid(n));   % directions, so summation
                output.Tp.data(n)      = Trans(WCmat(ii,jj)).Tp(s.Loc.M,s.Loc.N)   * ym6.Tp.data(vid(n));
            elseif (~isnan(eur.Hm0.data(vid(n))) & ~isnan(WCmat(ii,jj)) & ym6.Th0.data(n)<280);
                output.Hm0.data(n)     = Trans(WCmat(ii,jj)).Hs(s.Loc.M,s.Loc.N)   * eur.Hm0.data(vid(n));
                output.Hdir.data(n)    = Trans(WCmat(ii,jj)).Hdir(s.Loc.M,s.Loc.N) + eur.Th0.data(vid(n));   % directions, so summation
                output.Tp.data(n)      = Trans(WCmat(ii,jj)).Tp(s.Loc.M,s.Loc.N)   * eur.Tp.data(vid(n));
            else;
                output.Hm0.data(n)     = NaN;
                output.Hdir.data(n)    = NaN;
                output.Tp.data(n)      = NaN;
            end;

        elseif s.Loc.N >= 105 & s.Loc.N <205

            if (~isnan(eld.Hm0.data(vid(n))) & ~isnan(WCmat(ii,jj)) & ym6.Th0.data(n)>300);
                output.Hm0.data(n)     = Trans(WCmat(ii,jj)).Hs(s.Loc.M,s.Loc.N)   * eld.Hm0.data(vid(n));
                output.Hdir.data(n)    = Trans(WCmat(ii,jj)).Hdir(s.Loc.M,s.Loc.N) + eld.Th0.data(vid(n));   % directions, so summation
                output.Tp.data(n)      = Trans(WCmat(ii,jj)).Tp(s.Loc.M,s.Loc.N)   * eld.Tp.data(vid(n));
            elseif (~isnan(ym6.Hm0.data(vid(n))) & ~isnan(WCmat(ii,jj)) & ym6.Th0.data(n)<300);
                output.Hm0.data(n)     = Trans(WCmat(ii,jj)).Hs(s.Loc.M,s.Loc.N)   * ym6.Hm0.data(vid(n));
                output.Hdir.data(n)    = Trans(WCmat(ii,jj)).Hdir(s.Loc.M,s.Loc.N) + ym6.Th0.data(vid(n));   % directions, so summation
                output.Tp.data(n)      = Trans(WCmat(ii,jj)).Tp(s.Loc.M,s.Loc.N)   * ym6.Tp.data(vid(n));
            else;
                output.Hm0.data(n)     = NaN;
                output.Hdir.data(n)    = NaN;
                output.Tp.data(n)      = NaN;
            end;

        elseif s.Loc.N >= 205;

            if (~isnan(eld.Hm0.data(vid(n))) & ~isnan(WCmat(ii,jj)));
                output.Hm0.data(n)     = Trans(WCmat(ii,jj)).Hs(s.Loc.M,s.Loc.N)   * eld.Hm0.data(vid(n));
                output.Hdir.data(n)    = Trans(WCmat(ii,jj)).Hdir(s.Loc.M,s.Loc.N) + eld.Th0.data(vid(n));   % directions, so summation
                output.Tp.data(n)      = Trans(WCmat(ii,jj)).Tp(s.Loc.M,s.Loc.N)   * eld.Tp.data(vid(n));
            else;
                output.Hm0.data(n)     = NaN;
                output.Hdir.data(n)    = NaN;
                output.Tp.data(n)      = NaN;
            end;

        end

        % Surge determination on basis of nearest offshore location
        if s.Loc.N < 45
                output.surge.data(n)   = Trans(WCmat(ii,jj)).Surge(s.Loc.M,s.Loc.N)+ eur.surge.data(vid(n));
        elseif s.Loc.N >= 45 & s.Loc.N <81
                output.surge.data(n)   = Trans(WCmat(ii,jj)).Surge(s.Loc.M,s.Loc.N)+ ym6.surge.data(vid(n));
        elseif s.Loc.N >= 81;
                output.surge.data(n)   = Trans(WCmat(ii,jj)).Surge(s.Loc.M,s.Loc.N)+ eld.surge.data(vid(n));
        end

        if isnan(output.Hdir.data(n));
            output.surge.data(n) = NaN; 
        end
    end
end
close(hh)

% make directions from 0-360 deg.
output.Hdir.data(output.Hdir.data<0)   = output.Hdir.data(output.Hdir.data<0)   + 360;
output.Hdir.data(output.Hdir.data>360) = output.Hdir.data(output.Hdir.data>360) - 360;

%% export data
Output.Data  = [output.Hm0.data;output.Hdir.data;output.Tp.data;output.surge.data]';
Output.Time  = [ym6.Date(vid) ym6.Time(vid)];

if s.Loc.N > 205;
    k=warndlg(sprintf('Note: The results of the wave transformation at this location \n           may be not very accurate! \n The wave transformation matrix is build for the area between ELD and EUR'), '!! Warning !!')
else; end

fid = fopen(s.OutputFile,'w');
fprintf(fid,'%s\n','Transformed wave data from the offshore platforms ELD, YM6 and EUR to nearshore');
fprintf(fid,'%s\n','NaN values mean that the wave direction is between 30-200 deg, so no transformation is done');
fprintf(fid,'%s\n',['* Output Location X: ' num2str(s.Loc.X) ' [m; RD]']);
fprintf(fid,'%s\n',['* Output Location Y: ' num2str(s.Loc.Y) ' [m; RD]']);
fprintf(fid,'%s\n','* column 1 = Date');
fprintf(fid,'%s\n','* column 2 = Time');
fprintf(fid,'%s\n','* column 3 = Hm0   (m)');
fprintf(fid,'%s\n','* column 4 = Hdir  (deg N)');
fprintf(fid,'%s\n','* column 5 = Tp  (s)');
fprintf(fid,'%s\n','* column 6 = Surge (m)');
for i=1:size(vid,1)
    fprintf(fid,'%s',[Output.Time{i,1} '  ' Output.Time{i,2}]);
    fprintf(fid,[repmat('%8.3f   ',1,size(Output.Data,2)) '\n'],Output.Data(i,:)');
end
fclose(fid);

%% figure
time = datenum([cell2mat(ym6.Date(vid)) cell2mat(ym6.Time(vid))],'yyyymmddHHMMSS');
figure('PaperType','A4','PaperOrientation','landscape');
subplot(3,1,1)
plot(time,Output.Data(:,1),'b*')
datetick('x','keeplimits')
xlim([time(1) time(end)])
yy = [0:1:10];
set(gca,'YTick',yy,'YTickLabel',yy)
ylim([yy(1) yy(end)])
title('Hm0 [m]','FontWeight','bold');
grid on; box on;

subplot(3,1,2)
plot(time,Output.Data(:,2),'b*')
datetick('x','keeplimits')
xlim([time(1) time(end)])
yy = [0:30:360];
set(gca,'YTick',yy,'YTickLabel',yy)
ylim([yy(1) yy(end)])
title('Wave direction [°N]','FontWeight','bold');
grid on; box on;

subplot(3,1,3)
plot(time,Output.Data(:,3),'b*')
datetick('x','keeplimits')
xlim([time(1) time(end)])
yy = [0:1:10];
set(gca,'YTick',yy,'YTickLabel',yy)
ylim([yy(1) yy(end)])
title('Tp [s]','FontWeight','bold');
grid on; box on;

print(gcf,'-dpng','-painters',[s.OutputFile(1:end-4)]);

