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
%morphological initial file creation

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998' 
%   -simdef.runid.serie = run serie [string] e.g. 'A'
%   -simdef.runid.number = run identification number [integer(1,1)] e.g. 36
%
%OUTPUT:
%   -a configuration .xml file compatible with D3D is created in file_name

function D3D_xml(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

dire_sim=simdef.D3D.dire_sim;

%% FILE

switch simdef.D3D.structure
    case 1
data{1  ,1}='<?xml version="1.0" encoding="iso-8859-1"?>';
data{2  ,1}='<deltaresHydro xmlns="http://schemas.deltares.nl/deltaresHydro" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.deltares.nl/deltaresHydro http://content.oss.deltares.nl/schemas/d_hydro-1.00.xsd">';
data{3  ,1}='    <documentation>';
data{4  ,1}='        File created by    : chavosbky';
data{5  ,1}='        File creation date : today :D';
data{6  ,1}='        File version       : 1.00';
data{7  ,1}='    </documentation>';
data{8  ,1}='    <control>';
data{9  ,1}='        <sequence>';
data{10 ,1}='            <start>myNameFlow</start>';
data{11 ,1}='        </sequence>';
data{12 ,1}='    </control>';
data{13 ,1}='    <flow2D3D name="myNameFlow">';
data{14 ,1}='        <library>flow2d3d</library>';
% data{15 ,1}=sprintf('        <mdfFile>sim_%s%03d.mdf</mdfFile>',simdef.runid.serie,simdef.runid.number);
% data{15 ,1}=sprintf('        <mdfFile>sim_%s%s.mdf</mdfFile>',simdef.runid.serie,simdef.runid.number);
data{15 ,1}=sprintf('        <mdfFile>%s.mdf</mdfFile>',simdef.runid.name);
data{16 ,1}='        <!--';
data{17 ,1}='            Note: exactly one mdfFile (single domain) or ddbFile (domain decomposition)';
data{18 ,1}='            element must be present.';
data{19 ,1}='        -->';
data{20 ,1}='        <!--';
data{21 ,1}='            Options/alternatives:';
data{22 ,1}='            1) DomainDecomposition: replace <mdfFile>f34.mdf</mdfFile> with:';
data{23 ,1}='                <ddbFile>vlissingen.ddb</ddbFile>';
data{24 ,1}='            2) Specification of dll/so to use:';
data{25 ,1}='                <library>/opt/delft3d/lnx64/flow2d3d/bin/libflow2d3d.so</library>';
data{26 ,1}='            3) Single precision:';
data{27 ,1}='                <library>flow2d3d_sp</library>';
data{28 ,1}='            4) Documentation:';
data{29 ,1}='                <documentation>';
data{30 ,1}='                    Basic tutorial testcase.';
data{31 ,1}='                </documentation>';
data{32 ,1}='            5) More output to screen (silent, error, info, trace. default: error):';
data{33 ,1}='                <verbosity>trace</verbosity>';
data{34 ,1}='            6) Debugging by attaching to running processes (parallel run):';
data{35 ,1}='                <waitFile>debug.txt</waitFile>';
data{36 ,1}='            7) Force stack trace to be written (Linux only):';
data{37 ,1}='                <crashOnAbort>true</crashOnAbort>';
data{38 ,1}='        -->';
data{39 ,1}='    </flow2D3D>';
data{40 ,1}='    <delftOnline>';
data{41 ,1}='        <enabled>false</enabled>';
data{42 ,1}='        <urlFile>zzz.url</urlFile>';
data{43 ,1}='        <waitOnStart>false</waitOnStart>';
data{44 ,1}='        <clientControl>true</clientControl>    <!-- client allowed to start, step, stop, terminate -->';
data{45 ,1}='        <clientWrite>false</clientWrite>    <!-- client allowed to modify data -->';
data{46 ,1}='        <!--';
data{47 ,1}='            Options/alternatives:';
data{48 ,1}='            1) Change port range:';
data{49 ,1}='                <tcpPortRange start="51001" end="51099"/>';
data{50 ,1}='            2) More output to screen (silent, error, info, trace. default: error):';
data{51 ,1}='                <verbosity>trace</verbosity>';
data{52 ,1}='            3) Force stack trace to be written (Linux only):';
data{53 ,1}='                <crashOnAbort>true</crashOnAbort>';
data{54 ,1}='        -->';
data{55 ,1}='    </delftOnline>';
data{56 ,1}='</deltaresHydro>';

%         switch simdef.D3D.compile
%             case 0 %DIMR
                file_name=fullfile(dire_sim,'config_d_hydro.xml');
%             otherwise
%                 file_name=fullfile(dire_sim,'config_flow2d3d.xml');
%         end
% file_name=fullfile(dire_sim,'dimr_config.xml');
    case 2
kl=1;
data{kl,1}='<?xml version="1.0" encoding="iso-8859-1"?>                                                                                                                                                                                          '; kl=kl+1;
data{kl,1}='<dimrConfig xmlns="http://schemas.deltares.nl/dimrConfig" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.deltares.nl/dimrConfig http://content.oss.deltares.nl/schemas/d_hydro-1.00.xsd">  '; kl=kl+1;
data{kl,1}='    <documentation>                                                                                                                                                                                                                  '; kl=kl+1;
data{kl,1}='        <fileVersion>1.00</fileVersion>                                                                                                                                                                                              '; kl=kl+1;
data{kl,1}='        <createdBy>Deltares, Sobek3 To D-Flow FM converter, version 1.17</createdBy>                                                                                                                                                 '; kl=kl+1;
data{kl,1}='        <creationDate>2019-12-03 15:33</creationDate>                                                                                                                                                                                '; kl=kl+1;
data{kl,1}='    </documentation>                                                                                                                                                                                                                 '; kl=kl+1;
data{kl,1}='    <control>                                                                                                                                                                                                                        '; kl=kl+1;
data{kl,1}='        <start name="myNameDFlowFM"/>                                                                                                                                                                                                '; kl=kl+1;
data{kl,1}='    </control>                                                                                                                                                                                                                       '; kl=kl+1;
data{kl,1}='    <component name="myNameDFlowFM">                                                                                                                                                                                                 '; kl=kl+1;
data{kl,1}='        <library>dflowfm</library>                                                                                                                                                                                                   '; kl=kl+1;
data{kl,1}='        <workingDir>.</workingDir>                                                                                                                                                                                                   '; kl=kl+1;
data{kl,1}=sprintf('        <inputFile>%s.mdu</inputFile>',simdef.runid.name); kl=kl+1;
data{kl,1}='    </component>                                                                                                                                                                                                                     '; kl=kl+1;
data{kl,1}='</dimrConfig>                                                                                                                                                                                                                        '; kl=kl+1;

file_name=fullfile(dire_sim,'dimr_config.xml');
end

%% WRITE


% file_name=fullfile(dire_sim,'config_d_hydro.xml');
writetxt(file_name,data,'check_existing',check_existing);