%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%

function D3D_dimr_config(fpath_xml,fname_mdu)

fid=fopen(fpath_xml,'w');

fprintf(fid,'<?xml version="1.0" encoding="iso-8859-1"?>                                                                                                                                                                                        \r\n');
fprintf(fid,'<dimrConfig xmlns="http://schemas.deltares.nl/dimrConfig" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.deltares.nl/dimrConfig http://content.oss.deltares.nl/schemas/d_hydro-1.00.xsd">\r\n');
fprintf(fid,'    <documentation>                                                                                                                                                                                                                \r\n');
fprintf(fid,'        <fileVersion>1.00</fileVersion>                                                                                                                                                                                            \r\n');
fprintf(fid,'        <createdBy>V</createdBy>                                                                                                                                               \r\n');
fprintf(fid,'        <creationDate>%s</creationDate>                                                                                                                                                                              \r\n',datestr(datetime('now')));
fprintf(fid,'    </documentation>                                                                                                                                                                                                               \r\n');
fprintf(fid,'    <control>                                                                                                                                                                                                                      \r\n');
fprintf(fid,'        <start name="myNameDFlowFM"/>                                                                                                                                                                                              \r\n');
fprintf(fid,'    </control>                                                                                                                                                                                                                     \r\n');
fprintf(fid,'    <component name="myNameDFlowFM">                                                                                                                                                                                               \r\n');
fprintf(fid,'        <library>dflowfm</library>                                                                                                                                                                                                 \r\n');
fprintf(fid,'        <workingDir>.</workingDir>                                                                                                                                                                                                 \r\n');
fprintf(fid,'        <inputFile>%s</inputFile>                                                                                                                                                                                                  \r\n',fname_mdu);
fprintf(fid,'    </component>                                                                                                                                                                                                                   \r\n');
fprintf(fid,'</dimrConfig>                                                                                                                                                                                                                      \r\n');

fclose(fid);

end %xmlfile