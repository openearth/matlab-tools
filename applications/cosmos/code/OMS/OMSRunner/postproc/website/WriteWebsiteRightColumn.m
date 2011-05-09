function WriteWebsiteRightColumn(fid,ilevel)

bcksl=repmat('../',1,ilevel);

fprintf(fid,'%s\n','        <div id="rightcolumn">');
fprintf(fid,'%s\n','           <h3>your ad here</h3>');
fprintf(fid,'%s\n','           <p>Make us rich. Put your ad here ... </p>');
fprintf(fid,'%s\n','           <p class="continued"><a href="">Read more</a></p>');
fprintf(fid,'%s\n',['           <img class="ads" src="' bcksl 'img/RUMMERY1_VB.jpg"/>']);
fprintf(fid,'%s\n','        </div> <!-- end #sidebar -->');
fprintf(fid,'%s\n','');