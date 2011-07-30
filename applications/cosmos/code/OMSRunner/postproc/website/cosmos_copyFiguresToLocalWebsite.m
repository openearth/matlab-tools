function cosmos_copyFiguresToLocalWebsite(hm,m)

model=hm.models(m);

for iw=1:length(model.webSite)

    wbdir=model.webSite(iw).name;

    try
        dr=hm.models(m).dir;
        cont=hm.models(m).continent;
        dir1=[dr 'lastrun' filesep 'figures' filesep '*.*'];
        MakeDir([hm.webDir 'scenarios' filesep],hm.scenario,cont,hm.models(m).name,'figures');
        dir2=[hm.webDir 'scenarios' filesep  hm.scenario filesep  cont  filesep  hm.models(m).name filesep 'figures'];
        delete([dir2 filesep '*.*']);
        [status,message,messageid]=copyfile(dir1,dir2,'f');
    catch
        disp(['Something went wrong with copying to local website - ' hm.models(m).name]);
    end

    % try
    %     dr=hm.models(m).dir;
    %     cont=hm.models(m).continent;
    %     dir1=[dr 'lastrun' filesep 'figures' filesep '*.*'];
    %     MakeDir([hm.webDir hm.models(m).webSite filesep 'scenarios' filesep ],hm.scenario,cont,hm.models(m).name,'figures');
    %     dir2=[hm.webDir hm.models(m).webSite filesep 'scenarios' filesep  hm.scenario ...
    %            filesep  cont  filesep  hm.models(m).name  filesep 'figures'];
    %     delete([dir2  filesep '*.*']);
    %     [status,message,messageid]=copyfile(dir1,dir2,'f');
    % catch
    %     disp(['Something went wrong with copying to local website - ' hm.models(m).name]);
    % end

end
