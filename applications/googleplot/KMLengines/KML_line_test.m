function testresult = KML_line_test()
%KML_line_test  test for KML_line
%
% Please compare results of KML_line and KML_poly at a lagre zoom level.
%
%See also: KML_line, KML_Poly_test

disp(['... running test:',mfilename])

%% $Description (Name = KMLpcolor)
% Publishable code that describes the test.

%% $RunCode
try

   %% compare this one to KML_poly_test

   lat = [52 52 53 53]';
   lon = [ 3  4  4  3]'+1;
   nam = '4x1';

   OPT.fid = fopen(KML_testdir(['KML_line',nam,'.kml']),'w');
   output = [];
   output = [output KML_header('name',nam)];
   output = [output KML_stylePoly('name','default')];
   output = [output KML_line(lat ,lon ,'styleName','default')];
   output = [output KML_footer];
   fprintf(OPT.fid,output);
   fclose(OPT.fid);

   %% example 2

   fid         = fopen(KML_testdir('KML_line_red_world_spiral.kml'),'w');
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