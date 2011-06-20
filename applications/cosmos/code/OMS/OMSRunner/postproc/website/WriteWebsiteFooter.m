function WriteWebsiteFooter(fid,varargin)

if nargin==1
    includecounter=0;
else
    includecounter=varargin{1};
end

fprintf(fid,'%s\n','            <div id="footer">');
fprintf(fid,'%s\n','                <h3>about this website</h3>');
fprintf(fid,'%s\n','                <p>All information found on this website is purely experimental. It should not be used, for anything!</p>');
fprintf(fid,'%s\n','            </div> <!-- end #footer -->');
fprintf(fid,'%s\n','');
if includecounter
    fprintf(fid,'%s\n','            <!-- Start of StatCounter Code -->');
    fprintf(fid,'%s\n','            <script type="text/javascript">');
    fprintf(fid,'%s\n','            var sc_project=4644883;');
    fprintf(fid,'%s\n','            var sc_invisible=0;');
    fprintf(fid,'%s\n','            var sc_partition=56;');
    fprintf(fid,'%s\n','            var sc_click_stat=1;');
    fprintf(fid,'%s\n','            var sc_security="d1796e08";');
    fprintf(fid,'%s\n','            </script>');
    fprintf(fid,'%s\n','');
    fprintf(fid,'%s\n','            <script type="text/javascript" src="http://www.statcounter.com/counter/counter.js"></script>');
    fprintf(fid,'%s\n','            <noscript>');
    fprintf(fid,'%s\n','            <div class="statcounter">');
    fprintf(fid,'%s\n','                <a title="free web stats" href="http://my.statcounter.com/project/standard/stats.php?project_id=4644883&amp;guest=1" target="_blank"> <img class="statcounter" src="http://c.statcounter.com/4644883/0/d1796e08/0/"	alt="free web stats" ></a>');
    fprintf(fid,'%s\n','            </div>');
    fprintf(fid,'%s\n','            </noscript>');
    fprintf(fid,'%s\n','            <!-- End of StatCounter Code -->');
    fprintf(fid,'%s\n','            <p><a href="http://my.statcounter.com/project/standard/stats.php?project_id=4644883&amp;guest=1">Stats</a></p>');
    fprintf(fid,'%s\n','');
end
fprintf(fid,'%s\n','        </div> <!-- end #screen -->');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','    </div> <!-- end #wrap -->');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','</body>');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','</html>');
