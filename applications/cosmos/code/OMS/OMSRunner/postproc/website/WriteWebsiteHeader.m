function WriteWebsiteHeader(fid,hm,navpag,gmap,bannerfile)

if gmap
    fprintf(fid,'%s\n','<body onload="initialize()" onunload="GUnload()">');
else
    fprintf(fid,'%s\n','<body>');
end
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','    <div id="wrap">');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','        <div id="screen">');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','            <div id="header">');
fprintf(fid,'%s\n',['               <img src="' hm.MainURL bannerfile '"/>']);
fprintf(fid,'%s\n','                <p id="navbuttons">');

for i=1:length(hm.navpags)
    if i<length(hm.navpags)
        bullet='&#8226;';
    else
        bullet='';
    end
    if strcmpi(navpag,hm.navpags{i})
       fprintf(fid,'%s\n',['                <a id="activeLink"                    class="navlink" >' hm.navpags{i} ' ' bullet]);
    else
       fprintf(fid,'%s\n',['                <a href="' hm.MainURL hm.navpagslink{i} '" class="navlink" >' hm.navpags{i} ' </a>' bullet]);
    end
end    
fprintf(fid,'%s\n','                <p></p>');
fprintf(fid,'%s\n','            </div> <!-- end #header -->');
fprintf(fid,'%s\n','');

