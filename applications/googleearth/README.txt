Readme:

This toolbox needs to be added to the matlab path before use.
for example:

>> addpath('/home/sdavis/googlearth')

from the matlab command prompt.



Bugs, Known Issues:

Probably quite a few... but this is still a relatively new project.



Contact: Scott Davis sdavis@science.uva.nl    http://staff.science.uva.nl/~sdavis/



Revision History:


Oct 31, 2007
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


* fixed line 24 of authoptions.m... changed be_barbdaes to ge_barbdaes
* added 'authoptions' line 10 back to barbdaes.
* added 'rotation' to parameter list for ge_groundoverlay
* added 'labels' to parameter list of ge_colorbar, output in description matching levels
* changed ge_imagesc to create image graphics HUGE increase in speed & size capability
* added 'imageURL' to parameter list for ge_imagesc
* added 'polyAlpha','altitude','altitudeMode','extrude', & timestamps to ge_groundoverlay
* fixed ge_plot line 51 for try block handling of unknown data set issue... better fix later.
* changed ge_quiver for aspect ratio and modified output accuracy
* changed ge_surf to handle mx1 & mxn input data.  Might need more work, but demo works.
* updated and verified '/demos' directory.
* updated parameter lists in help html documents '/html' directory


August 24th, 2007
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


* changed pointDataCell in ge_point to allow fully user-defined tables in description field.  If not pointDataCell specified, default output is [ lat,lon,alt,date(s) ]
* commented out line 42 to 45 of ge_imagesc... 
* removed 'authoptions' line 10 from ge_barbdaes
* added 2d x,y,z functionality to ge_surf for more like real function usage.
* fixed ge_barbdaes for relative path fix on macos
* re-added ge_surf_peaks_function.png to /html/images
* reversed direction (u&v) of ge_windbarb output
* added colormap to ge_contour
* added ge_contourf function 
* added lineValues (equiv to matrix 'v' in contour documentation) to ge_contour & ge_contourf
* added numLines (equiv to scalar 'n' in contour documentation) to ge_contour & ge_contourf


August 1, 2007
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


* removed magnitudeScale & magnitudeMax from ge_quiver
* removed viewBoundScale from ge_point
* added snippet option to all relevant functions
* fixed ge_kmz to allow spaces in URL
* created authoptions.m to create a standard entry point, furthering the idea is needed.
* removed id & idTag from Authorized options for everything.  Until a good way of working with 
   network links from within matlab is developed, it is just bloat.
* removed references to id & idTag in all html help files.
* added html_product_page.html for new 2007a link to help from matlab 'start' menu.
* removed all references to 'parsepairs' in documentation as it is not needed, and never called externally.


