function testresult = KML_poly_test
%KML_line_test  test for KML_poly
%
% Please compare results of KML_line and KML_poly at a lagre zoom level.
%
%See also: KML_poly, KML_line_test

disp(['... running test:',mfilename])

%% $Description (Name = KMLpcolor)
% Publishable code that describes the test.

%% $RunCode
try

   lat = [52 52 53 53]';
   lon = [ 3  4  4  3]';
   nam = '4x1';

   %% compare this one to KML_line_test

   OPT.fid = fopen(KML_testdir(['KML_poly',nam,'.kml']),'w');
   output = [];
   output = [output KML_header('name',nam)];
   output = [output KML_stylePoly('name','default')];
   output = [output KML_poly(lat ,lon ,'styleName','default')];
   output = [output KML_footer];
   fprintf(OPT.fid,output);
   fclose(OPT.fid);

   %% this one is supposed to crash
   
   % lat = lat';
   % lon = lon';
   % nam = '1x4';
   % 
   %     OPT.fid = fopen(KML_testdir(['KML_poly',nam,'.kml']),'w');
   %     output = [];
   %     output = [output KML_header   ('name',nam)];
   %     output = [output KML_stylePoly('name','default')];
   %     output = [output KML_poly(lat ,lon ,'styleName','default')];
   %     output = [output KML_footer];
   %     fprintf(OPT.fid,output);
   %     fclose(OPT.fid);
   
   testresult = true;
catch
   testresult = false;
end

%% EOF
