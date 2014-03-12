function varargout = t_tide2html(D,varargin)
%t_tide2html store t_tide constituents as IHO xml
%
% str = t_tide2xml(D) where D = t_tide2struc() or D = t_tide_read()
%
% Example: t_tide2xml(D,'filename','test.xml');
%
%See also: t_tide, t_tide2struc, t_tide_read, t_tide2html, t_tide2nc
%          http://www.ukho.gov.uk/AdmiraltyPartners/FGHO/Pages/TidalHarmonics.aspx

%          http://www.iho.int/mtg_docs/com_wg/IHOTC/IHOTC8/UK_HC_Exchange_format.pdf
%          http://www.iho.int/mtg_docs/com_wg/IHOTC/IHOTC8/Product_Spec_for_Exchange_of_HCs.pdf
%          http://www.iho.int/mtg_docs/com_wg/IHOTC/TWLWG%201/TWLWG1_4-3-1.pdf
%          http://tidesandcurrents.noaa.gov/faq2.html

% IHO xml keywords	 
   
D0.name                = '';
D0.country             = '';
D0.position.latitude   = '';
D0.position.longitude  = '';
D0.timeZone            = [];
D0.units               = '';
D0.observationStart    = '';
D0.observationEnd      = '';
D0.comments            = '';
   
OPT.filename           = '';

if nargin==0
    varargout = {OPT};
    return
end
OPT = setproperty(OPT,varargin);

str = '';
str = [str sprintf('<?xml version="1.0" encoding="UTF-8"?>')];
str = [str sprintf('<Transfer xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="HC_Schema_V1.xsd">')];
str = [str sprintf('	<Port>')];
str = [str sprintf('		<name>%s</name>',D.name)];
str = [str sprintf('		<country>%s</country>',D.country)];
str = [str sprintf('		<position>')];
str = [str sprintf('			<latitude>%s N</latitude>',  num2str(D.position.latitude))];  % string: example: -90 27.09S
str = [str sprintf('			<longitude>%s E</longitude>',num2str(D.position.longitude))]; % string: example: 109 27W
str = [str sprintf('		</position>')];
str = [str sprintf('		<timeZone>%s</timeZone>',D.timeZone)];% integer ???
str = [str sprintf('		<units>%s</units>',D.units)];
str = [str sprintf('		<observationStart>%s</observationStart>',D.observationStart)]; % date
str = [str sprintf('		<observationEnd>%s</observationEnd>',    D.observationEnd)]; % date
str = [str sprintf('		<comments>%s</comments>',    D.comments)];
str = [str sprintf('		<comments/>')];

for i=1:length(D.data.fmaj)
str = [str sprintf('		<Harmonic>')];
str = [str sprintf('			<name>%s</name>',D.data.name(i,:))];
str = [str sprintf('			<inferred>false</inferred>')];
str = [str sprintf('			<phaseAngle>%g</phaseAngle>',D.data.pha(i))];
str = [str sprintf('			<amplitude>%g</amplitude>',D.data.fmaj(i))];
str = [str sprintf('			<speed>%g</speed>',D.data.frequency(i))];
str = [str sprintf('		</Harmonic>')];
end
str = [str sprintf('	</Port>')];
str = [str sprintf('</Transfer>')];

if ~isempty(OPT.filename)
   savestr(OPT.filename,str)
end

if nargin==1
   varargout = {str};
end


%<?xml version="1.0" encoding="UTF-8"?>
%<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified" attributeFormDefault="unqualified">
%	<xs:element name="Transfer">
%		<xs:annotation>
%			<xs:documentation>International exchange format for Harmonic Constants</xs:documentation>
%		</xs:annotation>
%		<xs:complexType>
%			<xs:sequence>
%				<xs:element ref="Port" maxOccurs="unbounded"/>
%			</xs:sequence>
%		</xs:complexType>
%	</xs:element>
%	<xs:element name="Port">
%		<xs:complexType>
%			<xs:sequence>
%				<xs:element name="name" type="xs:string"/>
%				<xs:element name="country" type="xs:string"/>
%				<xs:element name="position">
%					<xs:complexType>
%						<xs:sequence>
%							<xs:element name="latitude" type="xs:string"/>
%							<xs:element name="longitude" type="xs:string"/>
%						</xs:sequence>
%					</xs:complexType>
%				</xs:element>
%				<xs:element name="timeZone" type="xs:integer"/>
%				<xs:element name="units">
%					<xs:simpleType>
%						<xs:restriction base="xs:string">
%							<xs:enumeration value="m"/>
%						</xs:restriction>
%					</xs:simpleType>
%				</xs:element>
%				<xs:element name="observationStart" type="xs:date"/>
%				<xs:element name="observationEnd" type="xs:date"/>
%				<xs:element name="comments" type="xs:string"/>
%				<xs:element ref="Harmonic" minOccurs="0" maxOccurs="unbounded"/>
%			</xs:sequence>
%		</xs:complexType>
%	</xs:element>
%	<xs:element name="Harmonic">
%		<xs:complexType>
%			<xs:sequence>
%				<xs:element name="name">
%					<xs:simpleType>
%						<xs:restriction base="xs:string">
%							<xs:pattern value="((Z|z)(O|o))|((S|s)(A|a))|((S|s)(S|s)(A|a))|((S|s)(T|t)(A|a))|((M|m)(S|s)(M|m))|((M|m)(N|n)(U|u)(M|m))|((M|m)(M|m))|((M|m)(S|s)(F|f))|((M|m)(S|s)(O|o))|((S|s)(M|m))|((M|m)(F|f))|((K|k)(O|o)(O|o))|((M|m)(K|k)(O|o))|((S|s)(N|n)(U|u)[2])|((S|s)(N|n))|((M|m)(S|s)(T|t)(M|m))|((M|m)(F|f)(M|m))|([2](S|s)(M|m))|((M|m)(S|s)(Q|q)(M|m))|((M|m)(Q|q)(M|m))|([2](S|s)(M|m)(N|n))|([2](Q|q)[1])|((N|n)(J|j)[1])|((N|n)(U|u)(J|j)[1])|((S|s)(I|i)(G|g)(M|m)(A|a)[1])|((Q|q)[1])|((N|n)(K|k)[1])|((R|r)(H|h)(O|o)[1])|((N|n)(U|u)(K|k)[1])|((O|o)[1])|((M|m)(K|k)[1])|((M|m)(S|s)[1])|((M|m)(P|p)[1])|((M|m)(P|p)[1])|((T|t)(A|a)(U|u)[1])|((M|m)[1](B|b))|((M|m)[1](B|b))|((M|m)[1](C|c))|((M|m)[1])|((M|m)[1])|((N|n)(O|o)[1])|((M|m)[1](A|a))|((M|m)[1])|((L|l)(P|p)[1])|((C|c)(H|h)(I|i)[1])|((P|p)(I|i)[1])|((T|t)(K|k)[1])|((P|p)[1])|((S|s)(K|k)[1])|((S|s)[1])|((S|s)[1])|((S|s)[1])|((S|s)(P|p)[1])|((K|k)[1])|((M|m)(O|o)[1])|((K|k)[1])|((R|r)(P|p)[1])|((P|p)(S|s)(I|i)[1])|((P|p)(H|h)(I|i)[1])|((K|k)(P|p)[1])|((L|l)(A|a)(M|m)(B|b)(D|d)(A|a)(O|o)[1])|((T|t)(H|h)(E|e)(T|t)(A|a)[1])|((M|m)(Q|q)[1])|((J|j)[1])|([2](P|p)(O|o)[1])|((S|s)(O|o)[1])|((S|s)(O|o)[1])|((O|o)(O|o)[1])|((U|u)(P|p)(S|s)[1])|((K|k)(Q|q)[1])|([2](M|m)(N|n)[2](S|s)[2])|([3](M|m)[(](S|s)(K|k)[)][2])|([3](M|m)(K|k)(S|s)[2])|([2](N|n)(S|s)[2])|([3](M|m)[2](S|s)[2])|([3](M|m)(S|s)[2])|([2](N|n)(K|k)[2](S|s)[2])|((O|o)(Q|q)[2])|((M|m)(N|n)(K|k)[2])|((O|o)(Q|q)[2])|((M|m)(N|n)(S|s)[2])|((E|e)(P|p)(S|s)[2])|((M|m)(N|n)(U|u)(S|s)[2])|([2](M|m)(L|l)[2](S|s)[2])|((M|m)(N|n)(K|k)[2](S|s)[2])|([2](M|m)(S|s)[2](K|k)[2])|([2](M|m)(K|k)[2])|((O|o)[2])|((N|n)(L|l)(K|k)[2])|([2](N|n)[2])|((M|m)(U|u)[2])|([2](M|m)(S|s)[2])|((S|s)(N|n)(K|k)[2])|((N|n)(A|a)[2])|((N|n)(A|a)[2])|((N|n)[2])|((K|k)(Q|q)[2])|((N|n)(B|b)[2])|((N|n)(A|a)[2][*])|((N|n)(U|u)[2])|([2](K|k)(N|n)[2](S|s)[2])|((M|m)(S|s)(K|k)[2])|((O|o)(P|p)[2])|((O|o)(P|p)[2])|((G|g)(A|a)(M|m)(M|m)(A|a)[2])|((M|m)(A|a)[2])|((M|m)(P|p)(S|s)[2])|((A|a)(L|l)(P|p)(H|h)(A|a)[2])|((M|m)[(](S|s)(K|k)[)][2])|((M|m)[2])|((K|k)(O|o)[2])|((M|m)[(](K|k)(S|s)[)][2])|((M|m)(S|s)(P|p)[2])|((M|m)(B|b)[2])|((M|m)(A|a)[2][*])|((M|m)(K|k)(S|s)[2])|((D|d)(E|e)(L|l)(T|t)(A|a)[2])|((M|m)[2][(](K|k)(S|s)[)][2])|([2](K|k)(M|m)[2](S|s)[2])|([2](S|s)(N|n)[(](M|m)(K|k)[)][2])|((L|l)(A|a)(M|m)(B|b)(D|d)(A|a)[2])|((L|l)[2])|([2](M|m)(N|n)[2])|((L|l)[2](A|a))|((L|l)[2](B|b))|((N|n)(K|k)(M|m)[2])|([2](S|s)(K|k)[2])|((T|t)[2])|((S|s)[2])|((K|k)(P|p)[2])|((R|r)[2])|((K|k)[2])|((M|m)(S|s)(N|n)(U|u)[2])|((M|m)(S|s)(N|n)[2])|((X|x)(I|i)[2])|((E|e)(T|t)(A|a)[2])|((K|k)(J|j)[2])|([2](K|k)(M|m)[(](S|s)(N|n)[)][2])|([2](S|s)(M|m)[2])|([2](M|m)(S|s)[2](N|n)[2])|((S|s)(K|k)(M|m)[2])|([2](S|s)(N|n)(U|u)[2])|([3][(](S|s)(M|m)[)](N|n)[2])|([2](S|s)(N|n)[2])|((S|s)(K|k)(N|n)[2])|([3](S|s)[2](M|m)[2])|([2](S|s)(K|k)[2](M|m)[2])|((M|m)(Q|q)[3])|((N|n)(O|o)[3])|((M|m)(Q|q)[3])|((N|n)(O|o)[3])|((M|m)(O|o)[3])|([2](M|m)(K|k)[3])|((M|m)(O|o)[3])|([2](N|n)(K|k)(M|m)[3])|([2](M|m)(S|s)[3])|([2](M|m)(P|p)[3])|((M|m)[3])|((N|n)(K|k)[3])|((N|n)(K|k)[3])|((S|s)(O|o)[3])|((M|m)(P|p)[3])|((M|m)(P|p)[3])|((M|m)(S|s)[3])|((M|m)(K|k)[3])|((M|m)(K|k)[3])|((N|n)(S|s)(O|o)[3])|([2](M|m)(Q|q)[3])|((S|s)(P|p)[3])|((S|s)(P|p)[3])|((S|s)[3])|((S|s)(K|k)[3])|((S|s)(K|k)[3])|((K|k)[3])|((K|k)[3])|([2](S|s)(O|o)[3])|([4](M|m)(S|s)[4])|([4](M|m)[2](S|s)[4])|([2](M|m)(N|n)(K|k)[4])|([3](N|n)(M|m)[4])|([2](M|m)(N|n)(S|s)[4])|([2](M|m)(N|n)(U|u)(S|s)[4])|([3](M|m)(K|k)[4])|((M|m)(N|n)(L|l)(K|k)[4])|((N|n)[4])|([2](N|n)[4])|([3](M|m)(S|s)[4])|([2](N|n)(K|k)(S|s)[4])|((M|m)(S|s)(N|n)(K|k)[4])|((M|m)(N|n)[4])|((M|m)(N|n)(U|u)[4])|([2](M|m)(L|l)(S|s)[4])|((M|m)(N|n)(K|k)(S|s)[4])|([2](M|m)(S|s)(K|k)[4])|((M|m)(A|a)[4])|((M|m)[4])|([2](M|m)(R|r)(S|s)[4])|([2](M|m)(K|k)(S|s)[4])|((S|s)(N|n)[4])|([3](M|m)(N|n)[4])|((M|m)(L|l)[4])|((M|m)(L|l)[4])|((K|k)(N|n)[4])|((N|n)(K|k)[4])|([2](S|s)(M|m)(K|k)[4])|((M|m)[2](S|s)(K|k)[4])|((M|m)(T|t)[4])|((M|m)(S|s)[4])|((M|m)(R|r)[4])|((M|m)(K|k)[4])|([2](S|s)(N|n)(M|m)[4])|([2](M|m)(S|s)(N|n)[4])|([2](M|m)(S|s)(N|n)[4])|((S|s)(L|l)[4])|([2](M|m)(K|k)(N|n)[4])|((S|s)(T|t)[4])|((S|s)[4])|((S|s)(K|k)[4])|((K|k)[4])|([3](S|s)(M|m)[4])|([2](S|s)(K|k)(M|m)[4])|((M|m)(N|n)(O|o)[5])|([2](M|m)(Q|q)[5])|([2](N|n)(K|k)(M|m)(S|s)[5])|([3](M|m)(K|k)[5])|([2](M|m)(O|o)[5])|([2](N|n)(K|k)[5])|([3](M|m)(S|s)[5])|([3](M|m)(P|p)[5])|((N|n)(S|s)(O|o)[5])|((M|m)[5])|((M|m)[5])|((M|m)[5])|((M|m)(N|n)(K|k)[5])|((M|m)(B|b)[5])|((M|m)(S|s)(O|o)[5])|([2](M|m)(P|p)[5])|([2](M|m)(S|s)[5])|([3](M|m)(O|o)[5])|([2](M|m)(K|k)[5])|((N|n)(S|s)(K|k)[5])|([3](M|m)(Q|q)[5])|((M|m)(S|s)(P|p)[5])|((M|m)(S|s)(K|k)[5])|((M|m)(S|s)(K|k)[5])|([3](K|k)(M|m)[5])|([2](S|s)(P|p)[5])|([2](S|s)(K|k)[5])|([(](S|s)(K|k)[)](K|k)[5])|([2][(](M|m)(N|n)[)](K|k)[6])|([5](M|m)(K|k)(S|s)[6])|([2][(](M|m)(N|n)[)](S|s)[6])|([5](M|m)[2](S|s)[6])|([3](M|m)(N|n)(K|k)[6])|((N|n)[6])|([3](M|m)(N|n)(S|s)[6])|([3](N|n)(K|k)(S|s)[6])|([3](M|m)(N|n)(U|u)(S|s)[6])|([4](M|m)(K|k)[6])|([2](N|n)(M|m)[6])|((M|m)[2](N|n)[6])|([4](M|m)(S|s)[6])|([2](N|n)(M|m)(K|k)(S|s)[6])|([2](M|m)(S|s)(N|n)(K|k)[6])|([2](M|m)(N|n)[6])|([2](M|m)(N|n)(U|u)[6])|([2](M|m)(N|n)(O|o)[6])|([2](M|m)(N|n)(K|k)(S|s)[6])|([3](M|m)(S|s)(K|k)[6])|((M|m)(A|a)[6])|((M|m)[6])|([3](M|m)(K|k)(S|s)[6])|((M|m)(T|t)(N|n)[6])|((M|m)(S|s)(N|n)[6])|([4](M|m)(N|n)[6])|([2](M|m)(L|l)[6])|((M|m)(N|n)(K|k)[6])|((M|m)(K|k)(N|n)[6])|((M|m)(K|k)(N|n)(U|u)[6])|([2][(](M|m)(S|s)[)](K|k)[6])|([2](M|m)(T|t)[6])|([2](M|m)(S|s)[6])|([2](M|m)(K|k)[6])|([2](S|s)(N|n)[6])|([3](M|m)(T|t)(N|n)[6])|([3](M|m)(S|s)(N|n)[6])|((M|m)(S|s)(L|l)[6])|((N|n)(S|s)(K|k)[6])|((S|s)(N|n)(K|k)[6])|((M|m)(K|k)(L|l)[6])|([3](M|m)(K|k)(N|n)[6])|((M|m)(S|s)(T|t)[6])|([2](S|s)(M|m)[6])|((M|m)(S|s)(K|k)[6])|((S|s)(K|k)(M|m)[6])|([2](K|k)(M|m)[6])|([2](M|m)(S|s)(T|t)(N|n)[6])|([2][(](M|m)(S|s)[)](N|n)[6])|([2](M|m)(S|s)(K|k)(N|n)[6])|((S|s)[6])|([2](M|m)(N|n)(O|o)[7])|([3](M|m)(Q|q)[7])|([4](M|m)(K|k)[7])|([2](N|n)(M|m)(K|k)[7])|((M|m)(N|n)(S|s)(O|o)[7])|((M|m)[7])|((M|m)[7])|([2](M|m)(N|n)(K|k)[7])|((M|m)(N|n)(K|k)(O|o)[7])|([2](M|m)(S|s)(O|o)[7])|([3](M|m)(K|k)[7])|((M|m)(S|s)(K|k)(O|o)[7])|([3](M|m)[2](N|n)(S|s)[8])|([4](M|m)(N|n)(S|s)[8])|([5](M|m)(K|k)[8])|([2][(](M|m)(N|n)[)][8])|([5](M|m)(S|s)[8])|([2][(](M|m)(N|n)[)](K|k)(S|s)[8])|([3](M|m)(S|s)(N|n)(K|k)[8])|([3](M|m)(N|n)[8])|([3](M|m)(N|n)(U|u)[8])|([3](M|m)(N|n)(K|k)(S|s)[8])|([4](M|m)(S|s)(K|k)[8])|((M|m)(A|a)[8])|((M|m)[8])|([4](M|m)(K|k)(S|s)[8])|([2](M|m)(S|s)(N|n)[8])|([3](M|m)(L|l)[8])|([2](M|m)(N|n)(K|k)[8])|([3](M|m)[2](S|s)(K|k)[8])|([2][(](N|n)(S|s)[)][8])|([3](M|m)(T|t)[8])|([3](M|m)(S|s)[8])|([3](M|m)(K|k)[8])|([2](S|s)(N|n)(M|m)[8])|([2](S|s)(M|m)(N|n)[8])|([2](M|m)(S|s)(L|l)[8])|((M|m)(S|s)(N|n)(K|k)[8])|([4](M|m)(S|s)(N|n)[8])|([2](M|m)(S|s)(T|t)[8])|([2][(](M|m)(S|s)[)][8])|([2](M|m)(S|s)(K|k)[8])|([2][(](M|m)(K|k)[)][8])|([3](S|s)(N|n)[8])|([2](S|s)(M|m)(L|l)[8])|([2](S|s)(K|k)(N|n)[8])|((M|m)(S|s)(K|k)(L|l)[8])|([3](S|s)(M|m)[8])|([2](S|s)(M|m)(K|k)[8])|((S|s)[8])|([3](M|m)(N|n)(O|o)[9])|([2](M|m)[2](N|n)(K|k)[9])|([2][(](M|m)(N|n)[)](K|k)[9])|((M|m)(A|a)[9])|([3](M|m)(N|n)(K|k)[9])|([4](M|m)(K|k)[9])|([3](M|m)(S|s)(K|k)[9])|([5](M|m)(N|n)(S|s)[1][0])|([3](M|m)[2](N|n)[1][0])|([6](M|m)(S|s)[1][0])|([3](M|m)[2](N|n)(K|k)(S|s)[1][0])|([4](M|m)(S|s)(N|n)(K|k)[1][0])|([4](M|m)(N|n)[1][0])|([4](M|m)(N|n)(U|u)[1][0])|([5](M|m)(S|s)(K|k)[1][0])|((M|m)[1][0])|([5](M|m)(K|k)(S|s)[1][0])|([3](M|m)(S|s)(N|n)[1][0])|([6](M|m)(N|n)[1][0])|([4](M|m)(L|l)[1][0])|([3](M|m)(N|n)(K|k)[1][0])|([2][(](S|s)(N|n)[)](M|m)[1][0])|([4](M|m)(S|s)[1][0])|([4](M|m)(K|k)[1][0])|([2][(](M|m)(S|s)[)](N|n)[1][0])|([2](M|m)(N|n)(S|s)(K|k)[1][0])|([5](M|m)(S|s)(N|n)[1][0])|([3](M|m)[2](S|s)[1][0])|([3](M|m)(S|s)(K|k)[1][0])|([3](S|s)(M|m)(N|n)[1][0])|([2](S|s)(M|m)(K|k)(N|n)[1][0])|([4](M|m)[2](S|s)(N|n)[1][0])|([3](S|s)[2](M|m)[1][0])|([2][(](M|m)(S|s)[)](K|k)[1][0])|([4](M|m)(S|s)(K|k)[1][1])|([5](M|m)[2](N|n)(S|s)[1][2])|([3][(](M|m)(N|n)[)][1][2])|([6](M|m)(N|n)(S|s)[1][2])|([4](M|m)[2](N|n)[1][2])|([7](M|m)(S|s)[1][2])|([4](M|m)[2](N|n)(K|k)(S|s)[1][2])|([5](M|m)(S|s)(N|n)(K|k)[1][2])|([3](N|n)[2](M|m)(S|s)[1][2])|([5](M|m)(N|n)[1][2])|([5](M|m)(N|n)(U|u)[1][2])|([6](M|m)(S|s)(K|k)[1][2])|([3](M|m)[2](S|s)(N|n)[1][2])|((M|m)(A|a)[1][2])|((M|m)[1][2])|([4](M|m)(S|s)(N|n)[1][2])|([4](M|m)(L|l)[1][2])|([4](M|m)(N|n)(K|k)[1][2])|([2][(](M|m)(S|s)(N|n)[)][1][2])|([5](M|m)(T|t)[1][2])|([5](M|m)(S|s)[1][2])|([5](M|m)(K|k)[1][2])|([3](M|m)[2](S|s)(N|n)[1][2])|([6](M|m)(S|s)(N|n)[1][2])|([3](M|m)(N|n)(K|k)(S|s)[1][2])|([5](M|m)(S|s)(N|n)[1][2])|([4](M|m)(S|s)(T|t)[1][2])|([4](M|m)[2](S|s)[1][2])|([4](M|m)(S|s)(K|k)[1][2])|([3][(](M|m)(S|s)[)][1][2])|([3](M|m)[2](S|s)(K|k)[1][2])|([5](M|m)(S|s)(N|n)[1][4])|([5](M|m)(N|n)(K|k)[1][4])|([6](M|m)(S|s)[1][4])"/>
%						</xs:restriction>
%					</xs:simpleType>
%				</xs:element>
%				<xs:element name="inferred" type="xs:boolean"/>
%				<xs:element name="phaseAngle" type="xs:string"/>
%				<xs:element name="amplitude" type="xs:string"/>
%				<xs:element name="speed" type="xs:string"/>
%				<xs:element name="xdo" type="xs:string" minOccurs="0"/>
%			</xs:sequence>
%		</xs:complexType>
%	</xs:element>
%</xs:schema>
