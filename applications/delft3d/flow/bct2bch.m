function bct2bch(bctfile,bchfile,tstart,tstop,ncomp,varargin)

% Create bch file from bct file
% e.g. bct2bch('DD_GOM2_4KM.bct','test.bch',datenum(2011,1,5),datenum(2011,1,6),4,'plot')

t2hfolder=fileparts(which('tyd2har.exe'));

icor=1;
deletetempfiles=1;
ianul=1;
iplot=0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'keeptemporaryfiles'}
                deletetempfiles=0;
            case{'includea0'}
                ianul=1;
            case{'plot'}
                iplot=1;
        end
    end
end

% Read bct file
bct=bct_io('read',bctfile);

ict=1;
ih=1;
nt=size(bct.Table(1).Data,1);
ntot=length(bct.Table);
nriv=0;
tref=bct.Table(1).ReferenceTime;
tref=num2str(tref);
tref=datenum(tref,'yyyymmdd');
start=bct.Table(1).Data(1,1);
stap=bct.Table(1).Data(2,1)-bct.Table(1).Data(1,1);
beg=(tstart-tref)*1440;
per=(tstop-tstart)*1440;

fid=fopen('tyd2har1.inp','wt');
fprintf(fid,'%i %i %i %i %i %i %12.1f %12.1f %i %12.1f %12.1f %i\n',ict,ih,ianul,nt,ntot,nriv,start,stap,ncomp,beg,per,icor);
fclose(fid);

fid=fopen('tyd2har2.inp','wt');
fprintf(fid,'%s\n','tyd2har1.inp');
fprintf(fid,'%s\n',bctfile);
fprintf(fid,'%s\n',bchfile);
fprintf(fid,'%s\n','tyd2har.log');
fclose(fid);

system([t2hfolder filesep 'tyd2har.exe<tyd2har2.inp']);

if deletetempfiles
    delete('tyd2har1.inp');
    delete('tyd2har2.inp');
end    

if iplot
    for ii=1:ntot
        bch=delft3d_io_bch('read',bchfile);
        tbct=tref+bct.Table(ii).Data(:,1)/1440;        
        it1=find(tbct==tstart);
        it2=find(tbct==tstop);        
        bctt=bct.Table(ii).Data(it1:it2,1);
        bctt=bctt-bctt(1);
        bctt=bctt/1440;
        bcta=bct.Table(ii).Data(it1:it2,2);
        bctb=bct.Table(ii).Data(it1:it2,3);

        bcht=bctt(1):10/1440:bctt(end)';
        bcha=zeros(size(bcht));
        bchb=bcha;
        for ic=2:bch.nof
            freq=bch.frequencies(ic); % deg/h
            freq=freq*24;             % deg/d
            freq=freq*pi/180;         % rad/d
            va=bch.amplitudes(1,ii,ic-1)*cos(freq*bcht-pi*bch.phases(1,ii,ic-1)/180);
            vb=bch.amplitudes(2,ii,ic-1)*cos(freq*bcht-pi*bch.phases(2,ii,ic-1)/180);
            bcha=bcha+va;
            bchb=bchb+vb;
        end
        figure(ii)
        subplot(2,1,1)
        plot(bcht,bcha,'b');hold on;
        plot(bctt,bcta,'r');hold on;
        subplot(2,1,2)
        plot(bcht,bchb,'b');hold on;
        plot(bctt,bctb,'r');hold on;
    end
end

% 1 1 0 4321 38 0 -20360 10 4 0 750 1
%  
% c **********************************************************************
% c     in de invoer file worden achtereenvolgens ingelezen:
% c     ict, ih, ianul, nt,  ntot, nriv, start, stap, nc, beg,  per,  icor
% c
% c     voorbeeld invoerfile:
% c     2    2   0      1297 37    2     0.     10.   12  6740. 1480  1
% c
% c **********************************************************************
% C
% C     VARIABELE  BETEKENIS
% C     ---------  ---------
% C     ict        (1/2) respectievelijk harm. comp. of tijdserie
% C     ih         wel/niet (1/2) oneven componenten meenemen
% C     ianul      niet/wel (0/1) a0 correctie
% C     nt         Aantal tijdstappen in tijdseriefile
% C     Ntot       AANTAL tidal openings (inclusief rivieren)
% C     nriv       AANTAL rivier openings
% C     START      STARTTIJD TIJDREEKS (IN MINUTEN T.O.V. ITDATE)
% C     STAP       STAPGROOTTE IN MINUTEN
% C     nc         aantal componenten
% C     beg        starttijd analyse
% C     per        periode van de analyse
% C     icor       niet/wel (0/1) correctie fasehoeken begin-eind
