function testresult = KML_line_test()
%KML_line_test  test for KML_line
%
%See also: KML_line

disp(['... running test:',mfilename])

%% $Description (Name = KMLpcolor)
% Publishable code that describes the test.

%% $RunCode
try

   fid         = fopen(KML_testdir('a_red_line.kml'),'w');
   S.name      = 'red';
   S.lineColor = [1 0 0];  % color of the lines in RGB (0..1) values
   S.lineAlpha = [1] ;     % transparency of the line, (0..1) with 0 transparent
   S.lineWidth = 1;        % line width, can be a fraction
   
   kml         = KML_header('name','curl');
   kml         = [kml KML_style(S)];
   kml         = [kml KML_line(-90:90,-180:2:180,0:1:180,'styleName',S.name)];
   kml         = [kml KML_footer];
   fprintf(fid,kml);
   fclose (fid);
   
   testresult = true;
catch
   testresult = false;
end

%% EOF