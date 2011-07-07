function WriteWebsiteEntry(fid,entry,ilevel)

bcksl=repmat('../',1,ilevel);

fprintf(fid,'%s\n','            <div class="entry">');
fprintf(fid,'%s\n',['               <h2>' entry.title '</h2>']);
fprintf(fid,'%s\n',['               <p class="date">' entry.date '</p>']);
fprintf(fid,'%s\n','               <div class="photo_text">');
fprintf(fid,'%s\n',['                  <p class="photo"><img src="' bcksl 'img/' entry.img '"/></p>']);
for i=1:length(entry.text)
    fprintf(fid,'%s\n',['                  <p>' entry.text{i} '</p>']);
end
fprintf(fid,'%s\n','               </div> <!-- end .photo_text -->');
fprintf(fid,'%s\n','            </div> <!-- end .entry -->');
fprintf(fid,'%s\n','');
