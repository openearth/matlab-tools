%script om golfvorm te bepalen deel 1, april 2012.
%In dit script worden :
% 1.de GRADE-10.000 jarige reeksen ingelezen
% 2.de golven geselecteerd
% 3.klasses aangemaakt

clear all
close all
%%
%inlezen afvoerreeksen
filename = '2000012310000_BorgharenHBV_Glue50.XML';
currentdir=pwd;
% indir = ('.\invoer')
filepath = [currentdir filesep 'invoer' filesep filename];

%open inputfile and read headerline
fid = fopen(filepath, 'rt');
headerline = fgetl (fid);
headerline = fgetl (fid);
% nj=20000;
% r=365.25*nj;
data2 = fscanf(fid, '%f');
Ncol=6; %6 kollommen
Nrow=length(data2)/Ncol;
data = reshape(data2, Ncol, Nrow);
clear data2

date=datenum(data(1,:),data(2,:),data(3,:));

% n=floor(length(data)./2);
% date1=datenum(data(1:n,1),data(1:n,2),data(1:n,3));
% date2=datenum(data((n+1):end,1),data((n+1):end,2),data((n+1):end,3));
% date=[date1; date2];

GRADE.discharge=data(6,:)';
GRADE.year=data(1,:)';
GRADE.month=data(2,:)';
GRADE.day=data(3,:)';
GRADE.date=date';

%hydrologisch jaar
yearNum = zeros(length(date),1);
yearNum((GRADE.month==10|GRADE.month==11|GRADE.month==12)) = 1;
% yearNum=yearNum';
yearNum = yearNum + GRADE.year;
GRADE.hydyear =yearNum;

clear data date date1 date2 yearNum

%%
%selectie golven via jaarmaxima
l=25; %#dagen voor en na

MAX = accumarray(GRADE.hydyear,GRADE.discharge,[],@max);%maximale afvoer
jaar=unique(GRADE.hydyear);

MAX_index = accumarray(GRADE.hydyear, 1:numel(GRADE.discharge) ,[], @(x) findmax(x,GRADE.discharge));

for i=1:length(MAX_index)
    golven(i,:) = (GRADE.discharge(MAX_index(i)-l:MAX_index(i)+l))';
end

% plot(1:51, golven(1:10,:))

%%
%selectie golven via POT
%threshold=?
%zichtduur=?


%%
%indelen golven per klasse (minimaal 100 golven per klasse)
C = flipud(sortrows(golven,l+1));
D= C(:,l+1);
% plot(1:51, C(1:10,:))

%klasse definieren, als dh1-6 kleiner is dan 100 moet je de klasses groter
%kiezen
k=[3250:-250:1500];
for i=1:length(k)
    I(i)=max(find(D>k(i)));
    if i>1
    dh(i)=I(i)-I(i-1);
    else
    dh(i)=I(i)-0;
    end
end

for j=1:length(k)
    if j==1
    Class{j}.wave=C(1:I(j),:);
    else
    Class{j}.wave=C((I(j-1)+1):I(j),:);
    end
end

% Class1=C(1:I1,:);
% Class2=C(I1+1:I2,:);
% Class3=C(I2+1:I3,:);
% Class4=C(I3+1:I4,:);
% Class5=C(I4+1:I5,:);
% Class6=C(I5+1:I6,:);
% Class7=C(I6+1:I7,:);

%opslaan
save  Class Class l




