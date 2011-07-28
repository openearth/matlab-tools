function cosmos_copyFiguresToLocalWebsite(hm,m)

Model=hm.Models(m);

for iw=1:length(Model.WebSite)

    wbdir=Model.WebSite(iw).Name;

    try
        dr=hm.Models(m).Dir;
        cont=hm.Models(m).Continent;
        dir1=[dr 'lastrun' filesep 'figures' filesep '*.*'];
        MakeDir([hm.WebDir 'scenarios' filesep],hm.Scenario,cont,hm.Models(m).Name,'figures');
        dir2=[hm.WebDir 'scenarios' filesep  hm.Scenario filesep  cont  filesep  hm.Models(m).Name filesep 'figures'];
        delete([dir2 filesep '*.*']);
        [status,message,messageid]=copyfile(dir1,dir2,'f');
    catch
        disp(['Something went wrong with copying to local website - ' hm.Models(m).Name]);
    end

    % try
    %     dr=hm.Models(m).Dir;
    %     cont=hm.Models(m).Continent;
    %     dir1=[dr 'lastrun' filesep 'figures' filesep '*.*'];
    %     MakeDir([hm.WebDir hm.Models(m).WebSite filesep 'scenarios' filesep ],hm.Scenario,cont,hm.Models(m).Name,'figures');
    %     dir2=[hm.WebDir hm.Models(m).WebSite filesep 'scenarios' filesep  hm.Scenario ...
    %            filesep  cont  filesep  hm.Models(m).Name  filesep 'figures'];
    %     delete([dir2  filesep '*.*']);
    %     [status,message,messageid]=copyfile(dir1,dir2,'f');
    % catch
    %     disp(['Something went wrong with copying to local website - ' hm.Models(m).Name]);
    % end

end
