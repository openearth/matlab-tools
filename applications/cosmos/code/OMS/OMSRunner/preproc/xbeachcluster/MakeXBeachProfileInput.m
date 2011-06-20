function ok=MakeXBeachProfileInput(hm,m,i)

ok=0;

Profile=hm.Models(m).Profile(i);

tmpdir=[hm.TempDir filesep hm.Models(m).Profile(i).Name filesep];

% flist=dir([tmpdir '*.sp2']);
% for i=1:length(flist)
%     Spec=readSWANSpec([tmpdir flist(i).name]);
%     if i==1
%         sp2.f=Spec.Freqs;
%         sp2.d=Spec.Dirs;
%     end
%     sp2.t=Spec.Time(1).Time;
%     f=Spec.Time(1).Points(1).Factor*Spec.Time(1).Points(1).Energy;
%     %     f=f';
%     sp2.S(:,:,i)=f;
% end
% 
% hthreshold=0.9;
% 
% [thetamin,thetamax]=get_thetarange2(sp2,hthreshold);

thetamin=0;

if ~isempty(thetamin)
    ok=1;
%     thetamin=max(thetamin,-90);
%     thetamax=min(thetamax,90);

    xrun=Profile.OriginX+cos(pi*Profile.Alpha/180)*Profile.dX;
    yrun=Profile.OriginY+sin(pi*Profile.Alpha/180)*Profile.dX;

    % make param.txt file to run Xbeach
    fid = fopen([tmpdir 'params.txt'],'w');
    fprintf(fid,'%s\n\n','----------------------------------------------------');
    fprintf(fid,'%s\n\n','Grid input');
    fprintf(fid,'%s\n',['nx       = ' num2str(Profile.nX)]);
    fprintf(fid,'%s\n','ny       = 0');
    fprintf(fid,'%s\n','xfile    = x.grd');
    fprintf(fid,'%s\n','yfile    = y.grd');
    fprintf(fid,'%s\n',['xori     = ' num2str(Profile.OriginX)]);
    fprintf(fid,'%s\n',['yori     = ' num2str(Profile.OriginY)]);
    fprintf(fid,'%s\n',['alfa     = ' num2str(Profile.Alpha)]);
    fprintf(fid,'%s\n',['depfile  = ' Profile.Name '.dep']);
    fprintf(fid,'%s\n','posdwn    = -1');
%     fprintf(fid,'%s\n','thetanaut = 1');
%     fprintf(fid,'%s\n',['thetamin = ' num2str(thetamin)]);
%     fprintf(fid,'%s\n',['thetamax = ' num2str(thetamax)]);
%     fprintf(fid,'%s\n',['dtheta   = ' num2str(Profile.dTheta)]);
    fprintf(fid,'%s\n','thetanaut = 0');
    fprintf(fid,'%s\n','thetamin  = -90');
    fprintf(fid,'%s\n','thetamax  = 90');
    fprintf(fid,'%s\n','dtheta    = 180');
    fprintf(fid,'%s\n','vardx     = 1');
    fprintf(fid,'%s\n','----------------------------------------------------');
    fprintf(fid,'%s\n','Numerics input');
    fprintf(fid,'%s\n','CFL      = 0.8');
    fprintf(fid,'%s\n','eps      = 0.01');
    fprintf(fid,'%s\n','----------------------------------------------------');
    fprintf(fid,'%s\n','Time input');
    fprintf(fid,'%s\n','tstart   = 0.');
    fprintf(fid,'%s\n',['tstop    = ' num2str(hm.Models(m).RunTime*60)]);
    fprintf(fid,'%s\n','taper	 = 100');
    fprintf(fid,'%s\n',['tintg    = ' num2str(hm.Models(m).MapTimeStep*60)]);
    fprintf(fid,'%s\n',['tintm    = ' num2str(hm.Models(m).MapTimeStep*60)]);
    %fprintf(fid,'%s\n',['tintp    = ' num2str(hm.Models(m).HisTimeStep*60)]);
    fprintf(fid,'%s\n',['tintp    = 60']);
    fprintf(fid,'%s\n','----------------------------------------------------');
    fprintf(fid,'%s\n','General constants');
    fprintf(fid,'%s\n','rho      = 1025');
    fprintf(fid,'%s\n','g        = 9.81');
    fprintf(fid,'%s\n','----------------------------------------------------');
    fprintf(fid,'%s\n','Boundary condition options');
    fprintf(fid,'%s\n','zs0file  = tide.txt');
    fprintf(fid,'%s\n','tideloc  = 1');
    fprintf(fid,'%s\n','zs0      = 0');
    fprintf(fid,'%s\n','paulrevere = 0');
    fprintf(fid,'%s\n','instat   = 5');
    fprintf(fid,'%s\n','leftwave = 1');
    fprintf(fid,'%s\n','rightwave = 1');
    fprintf(fid,'%s\n','----------------------------------------------------');
    fprintf(fid,'%s\n','Wave calculation options');
    fprintf(fid,'%s\n','break    = 1');
    fprintf(fid,'%s\n','roller   = 1');
    fprintf(fid,'%s\n','beta     = 0.1');
    fprintf(fid,'%s\n','refl 	 = 0');
    fprintf(fid,'%s\n','gamma    = 0.45');
    fprintf(fid,'%s\n','delta    = 0.0 ');
    fprintf(fid,'%s\n','n        = 10.');
    fprintf(fid,'%s\n','bcfile   = sp2list.txt');
    fprintf(fid,'%s\n','front    = 0');
    fprintf(fid,'%s\n','snel     = 1');
    fprintf(fid,'%s\n','oldwbc   = 0');
    fprintf(fid,'%s\n','----------------------------------------------------');
    fprintf(fid,'%s\n','Flow calculation options');
    fprintf(fid,'%s\n','nuh      = 0.1');
    fprintf(fid,'%s\n','nuhfac   = 1.0');
    if strcmpi(hm.Models(m).Continent,'europe')
%    fprintf(fid,'%s\n','C        = 30.');
    fprintf(fid,'%s\n','C        = 60.');
    else
    fprintf(fid,'%s\n','C        = 55.');
    end
    fprintf(fid,'%s\n','umin     = 0.01');
    fprintf(fid,'%s\n','----------------------------------------------------');
    fprintf(fid,'%s\n','Sediment transport calculation options');
    fprintf(fid,'%s\n','facua    = 0.10');
    if strcmpi(hm.Models(m).Continent,'europe')
    fprintf(fid,'%s\n','D50      = 0.0002');
    fprintf(fid,'%s\n','D90      = 0.0003');
    else
    fprintf(fid,'%s\n','D50      = 0.0003');
    fprintf(fid,'%s\n','D90      = 0.0005');
    end
    fprintf(fid,'%s\n','ngd      = 1');
    fprintf(fid,'%s\n','nd       = 30');
    fprintf(fid,'%s\n','ne_layer = sedlayer.dep');
    fprintf(fid,'%s\n','struct   = 1');
    if hm.Models(m).MorFac==0
        fprintf(fid,'%s\n','sedtrans = 0');
    else        
        fprintf(fid,'%s\n','sedtrans = 1');
    end
    fprintf(fid,'%s\n','sourcesink = 0');
    fprintf(fid,'%s\n','----------------------------------------------------');
    fprintf(fid,'%s\n','Morphological calculation options');
    fprintf(fid,'%s\n',['morfac   = ' num2str(hm.Models(m).MorFac)]);
    fprintf(fid,'%s\n','morstart = 3600');
    fprintf(fid,'%s\n','wetslp   = 0.15');
    fprintf(fid,'%s\n','----------------------------------------------------');
    fprintf(fid,'%s\n','Output options');
    fprintf(fid,'%s\n','nglobalvar = 3');
    fprintf(fid,'%s\n','zs');
    fprintf(fid,'%s\n','zb');
    fprintf(fid,'%s\n','wetz');
    fprintf(fid,'%s\n','nmeanvar = 6');
    fprintf(fid,'%s\n','H');
    fprintf(fid,'%s\n','thetamean');
    fprintf(fid,'%s\n','uu');
    fprintf(fid,'%s\n','vv');
    fprintf(fid,'%s\n','DR');
    fprintf(fid,'%s\n','zs');
%    fprintf(fid,'%s\n','nrugauge = 0');
    fprintf(fid,'%s\n','nrugauge = 1');
    fprintf(fid,'%s\n',[num2str(xrun) ' ' num2str(yrun) ' 6 zs#u#v#xw#yw#xz#']);
    fclose(fid);
end
