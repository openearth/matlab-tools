function OK = KMLtest
%KMLTEST   batch for all unit tests of googleplot
%
%See also: googleplot

 %% OK
 j=0;clear OK
 j=j+1;OK(j) = KMLcolorbar_test
 j=j+1;OK(j) = KMLcontour3_test
 j=j+1;OK(j) = KMLcontour_test
%j=j+1;OK(j) = KMLcontourf_test % worked in by Thijs
 j=j+1;OK(j) = KMLline_test
 j=j+1;OK(j) = KMLmarker_test
 j=j+1;OK(j) = KMLmesh_test
 j=j+1;OK(j) = KMLpatch_test
 j=j+1;OK(j) = KMLpcolor_test
 j=j+1;OK(j) = KMLquiver_test
 j=j+1;OK(j) = KMLscatter_test
 j=j+1;OK(j) = KMLsurf_test
%j=j+1;OK(j) = KMLtricontourf_test % worked in by Thijs
%j=j+1;OK(j) = KMLtricontourf3_test % worked in by Thijs
 j=j+1;OK(j) = KMLtrisurf_test
%j=j+1;OK(j) = KMLfig2pngNew_test % very slow

 %% merge
 j=j+1;OK(j) = KMLmerge_files_test
 
