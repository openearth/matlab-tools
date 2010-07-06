function vakloding_get_list(url)
%VAKLODING_GET_LIST  list of all kaartbladen and all times from opendap server
%
% vakloding_get_list(url)
%
% Example: for OpenEarth test and production server
%
%    vakloding_get_list('http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml')
%    vakloding_get_list('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml')
%
%See also: rijkswaterstaat


L = opendap_catalog(url);
L = sort(L);

for i=1:length(L)
    t{i} = nc_cf_time(L{i},'time');
   t0(i) = t{i}(1);
   t1(i) = t{i}(end);
   nt(i) = length(t{i});
   disp([num2str(i,'%0.3d'),' ',pad(filename(L{i}),' ',-21),': ',datestr(t0(i)),' - ',datestr(t1(i)),' ',num2str(nt(i))])
end

% http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml: 2010-jul-6
% 001 vaklodingenKB109_4948: 01-Jan-1976 - 01-Jan-2003 20
% 002 vaklodingenKB109_5150: 01-Jan-1976 - 02-Oct-2003 20
% 003 vaklodingenKB110_4746: 01-Jan-1964 - 01-Jan-2003 30
% 004 vaklodingenKB110_4948: 01-Jan-1968 - 01-Jan-2003 29
% 005 vaklodingenKB110_5150: 01-Jan-1968 - 09-Sep-2003 28
% 006 vaklodingenKB111_4544: 01-Jan-1964 - 22-Jan-2001 21
% 007 vaklodingenKB111_4746: 01-Jan-1964 - 01-Jan-2003 34
% 008 vaklodingenKB111_4948: 01-Jan-1964 - 01-Jan-2003 29
% 009 vaklodingenKB111_5150: 01-Jan-1968 - 08-Jul-2003 27
% 010 vaklodingenKB112_4342: 01-Jan-1989 - 22-Jun-2007 9
% 011 vaklodingenKB112_4544: 01-Jan-1960 - 09-Jan-2006 36
% 012 vaklodingenKB112_4746: 01-Jan-1960 - 07-Sep-2005 46
% 013 vaklodingenKB112_4948: 01-Jan-1960 - 07-Sep-2005 42
% 014 vaklodingenKB113_4342: 01-Jan-1960 - 14-Jun-2007 19
% 015 vaklodingenKB113_4544: 01-Jan-1960 - 09-Mar-2007 24
% 016 vaklodingenKB113_4746: 01-Jan-1960 - 07-Sep-2005 35
% 017 vaklodingenKB113_4948: 01-Jan-1950 - 25-Apr-2007 36
% 018 vaklodingenKB114_3938: 01-Jan-1989 - 01-Jan-1989 1
% 019 vaklodingenKB114_4140: 01-Jan-1960 - 16-Aug-2006 20
% 020 vaklodingenKB114_4342: 01-Jan-1960 - 09-Mar-2007 34
% 021 vaklodingenKB114_4544: 01-Jan-1960 - 14-Apr-2008 34
% 022 vaklodingenKB114_4746: 23-Apr-2002 - 14-Apr-2008 3
% 023 vaklodingenKB114_4948: 01-Jan-1950 - 26-Apr-2007 37
% 024 vaklodingenKB114_5150: 01-Jan-1955 - 15-Oct-2008 31
% 025 vaklodingenKB115_3736: 01-Jan-1989 - 01-Jan-1989 1
% 026 vaklodingenKB115_3938: 01-Jan-1964 - 04-Aug-2004 14
% 027 vaklodingenKB115_4140: 01-Jan-1964 - 07-Aug-2006 29
% 028 vaklodingenKB115_4342: 01-Jan-1960 - 08-Nov-2007 32
% 029 vaklodingenKB115_4544: 01-Jan-1960 - 09-Mar-2007 29
% 030 vaklodingenKB115_4746: 01-Jan-2001 - 14-Apr-2008 4
% 031 vaklodingenKB115_4948: 01-Jan-1955 - 02-Oct-2008 32
% 032 vaklodingenKB115_5150: 01-Jan-1955 - 02-Oct-2008 32
% 033 vaklodingenKB116_3736: 01-Jan-1989 - 11-Sep-2006 10
% 034 vaklodingenKB116_3938: 01-Jan-1957 - 11-Sep-2006 31
% 035 vaklodingenKB116_4140: 01-Jan-1957 - 01-Jan-2004 28
% 036 vaklodingenKB116_4342: 01-Jan-1964 - 16-Aug-2006 25
% 037 vaklodingenKB116_4544: 01-Jan-1986 - 21-Dec-2006 12
% 038 vaklodingenKB116_4746: 01-Jan-1973 - 21-Dec-2006 13
% 039 vaklodingenKB116_4948: 01-Jan-1955 - 20-Aug-2008 59
% 040 vaklodingenKB116_5150: 01-Jan-1955 - 20-Aug-2008 31
% 041 vaklodingenKB117_3534: 01-Apr-1993 - 06-Aug-2008 5
% 042 vaklodingenKB117_3736: 01-Jan-1964 - 11-Sep-2006 15
% 043 vaklodingenKB117_3938: 01-Jan-1964 - 11-Sep-2006 31
% 044 vaklodingenKB117_4140: 01-Jan-1957 - 17-Mar-2004 27
% 045 vaklodingenKB117_4544: 01-Jan-1986 - 26-Feb-2007 11
% 046 vaklodingenKB117_4746: 01-Jan-1986 - 21-Dec-2006 10
% 047 vaklodingenKB117_4948: 01-Jan-1951 - 12-Aug-2008 65
% 048 vaklodingenKB117_5150: 01-Jan-1951 - 13-Aug-2008 40
% 049 vaklodingenKB118_2928: 05-Mar-2001 - 05-Mar-2001 1
% 050 vaklodingenKB118_3130: 05-Mar-2001 - 16-Aug-2008 5
% 051 vaklodingenKB118_3332: 01-Aug-1997 - 07-Aug-2008 4
% 052 vaklodingenKB118_3534: 01-May-1990 - 10-May-2008 6
% 053 vaklodingenKB118_3736: 01-Jan-1964 - 01-May-2008 8
% 054 vaklodingenKB118_3938: 01-Jan-1964 - 01-May-2008 8
% 055 vaklodingenKB118_4140: 01-Jan-1957 - 01-Jan-1957 1
% 056 vaklodingenKB118_4544: 01-Jan-1986 - 04-Mar-2007 11
% 057 vaklodingenKB118_4746: 01-Jan-1988 - 30-Jan-2007 9
% 058 vaklodingenKB118_4948: 01-Jan-1951 - 10-Aug-2008 61
% 059 vaklodingenKB118_5150: 01-Jan-1951 - 10-Aug-2008 59
% 060 vaklodingenKB119_2524: 05-Mar-2001 - 05-Mar-2001 1
% 061 vaklodingenKB119_2726: 05-Mar-2001 - 20-Jun-2005 2
% 062 vaklodingenKB119_2928: 05-Mar-2001 - 16-Aug-2008 3
% 063 vaklodingenKB119_3130: 01-Dec-1996 - 31-Mar-2008 5
% 064 vaklodingenKB119_3332: 01-May-1990 - 31-Mar-2008 8
% 065 vaklodingenKB119_3534: 01-Apr-1990 - 07-May-2008 6
% 066 vaklodingenKB119_3736: 01-Apr-1990 - 10-May-2008 6
% 067 vaklodingenKB119_4544: 01-Jan-1992 - 25-Feb-2007 4
% 068 vaklodingenKB120_1918: 01-Jan-1926 - 07-Jul-2006 7
% 069 vaklodingenKB120_2120: 01-Jan-1926 - 13-Feb-2006 8
% 070 vaklodingenKB120_2322: 01-Jan-1926 - 19-Apr-2008 14
% 071 vaklodingenKB120_2524: 01-Oct-1987 - 10-Apr-2008 7
% 072 vaklodingenKB120_2726: 01-Dec-1987 - 09-Apr-2008 8
% 073 vaklodingenKB120_2928: 01-Sep-1990 - 18-Feb-2008 7
% 074 vaklodingenKB120_3130: 01-Apr-1990 - 18-Feb-2008 7
% 075 vaklodingenKB120_3332: 01-Apr-1990 - 31-Mar-2008 9
% 076 vaklodingenKB120_3534: 01-Apr-1990 - 07-May-2008 6
% 077 vaklodingenKB121_1716: 01-Jan-1926 - 26-Jul-2006 16
% 078 vaklodingenKB121_1918: 01-Jan-1926 - 21-Apr-2005 11
% 079 vaklodingenKB121_2120: 01-Jan-1926 - 13-Feb-2006 13
% 080 vaklodingenKB121_2322: 01-Jan-1926 - 19-Apr-2008 18
% 081 vaklodingenKB121_2524: 01-May-1987 - 10-Apr-2008 8
% 082 vaklodingenKB121_2726: 01-May-1987 - 09-Apr-2008 8
% 083 vaklodingenKB121_2928: 01-Apr-1990 - 18-Feb-2008 7
% 084 vaklodingenKB121_3130: 01-Apr-1990 - 24-Apr-2005 5
% 085 vaklodingenKB122_1514: 01-Jan-1926 - 20-Aug-2007 13
% 086 vaklodingenKB122_1716: 01-Jan-1926 - 26-Jul-2006 17
% 087 vaklodingenKB122_1918: 01-Jan-1926 - 21-Apr-2005 15
% 088 vaklodingenKB122_2120: 01-Jan-1926 - 13-Feb-2006 14
% 089 vaklodingenKB122_2322: 01-Jan-1926 - 05-Mar-2001 11
% 090 vaklodingenKB123_1312: 01-Aug-1992 - 07-Aug-2002 5
% 091 vaklodingenKB123_1514: 01-Jan-1926 - 07-Aug-2007 17
% 092 vaklodingenKB123_1716: 01-Jan-1926 - 26-Jul-2006 15
% 093 vaklodingenKB123_1918: 01-Jan-1926 - 14-Jan-2003 13
% 094 vaklodingenKB123_2120: 01-Jan-1926 - 27-Jan-2003 10
% 095 vaklodingenKB123_2322: 01-Jan-1926 - 13-Mar-2003 9
% 096 vaklodingenKB124_1312: 01-Jan-1926 - 07-Aug-2002 10
% 097 vaklodingenKB124_1514: 01-Jan-1926 - 01-Apr-2005 13
% 098 vaklodingenKB124_1716: 01-Jan-1926 - 02-Jul-2003 14
% 099 vaklodingenKB124_1918: 01-Jan-1926 - 22-Jan-2003 15
% 100 vaklodingenKB124_2120: 01-Jan-1926 - 27-Jan-2003 10
% 101 vaklodingenKB124_2322: 01-Sep-1985 - 11-Mar-2003 2
% 102 vaklodingenKB125_1110: 01-Apr-1998 - 27-Sep-2000 2
% 103 vaklodingenKB125_1312: 01-Jan-1926 - 25-Mar-2004 10
% 104 vaklodingenKB125_1514: 01-Jan-1926 - 11-Feb-2004 11
% 105 vaklodingenKB125_1716: 01-Jan-1926 - 01-Jul-2003 9
% 106 vaklodingenKB125_1918: 01-Jan-1926 - 16-Apr-2003 11
% 107 vaklodingenKB125_2120: 01-Jan-1926 - 02-Jul-2003 10
% 108 vaklodingenKB126_1110: 01-Jan-1926 - 01-Jul-2004 10
% 109 vaklodingenKB126_1312: 01-Jan-1926 - 25-May-2004 14
% 110 vaklodingenKB126_1514: 01-Jan-1926 - 11-Feb-2004 10
% 111 vaklodingenKB126_1716: 01-Jan-1926 - 01-Jul-2003 10
% 112 vaklodingenKB126_1918: 01-Jan-1926 - 01-Jul-2003 10
% 113 vaklodingenKB127_1110: 01-Jan-1926 - 01-Jul-2004 10
% 114 vaklodingenKB127_1312: 01-Jan-1926 - 25-May-2004 13
% 115 vaklodingenKB127_1514: 01-Jan-1926 - 25-May-2004 13
% 116 vaklodingenKB127_1716: 01-Jan-1926 - 01-Jul-2003 9
% 117 vaklodingenKB128_1110: 01-Jan-1926 - 22-Mar-2005 10
% 118 vaklodingenKB128_1312: 01-Jan-1926 - 07-Mar-2005 11
% 119 vaklodingenKB128_1514: 01-Jan-1926 - 21-Jun-2004 9
% 120 vaklodingenKB129_1110: 01-Jan-1926 - 13-Apr-2005 13
% 121 vaklodingenKB129_1312: 01-Jan-1926 - 17-Mar-2005 22
% 122 vaklodingenKB129_1514: 01-Jan-1926 - 07-Mar-2005 12
% 123 vaklodingenKB130_1110: 01-Jan-1927 - 20-Apr-2005 18
% 124 vaklodingenKB130_1312: 01-Jan-1927 - 17-Mar-2005 17
% 125 vaklodingenKB130_1514: 01-Jan-1927 - 01-Jan-1958 2
% 126 vaklodingenKB131_0908: 02-Apr-2001 - 19-Apr-2006 3
% 127 vaklodingenKB131_1110: 01-Jan-1927 - 17-Mar-2005 16
% 128 vaklodingenKB131_1312: 01-Jan-1927 - 16-Jan-2006 15
% 129 vaklodingenKB131_1514: 01-Jan-1927 - 01-Jan-1967 4
% 130 vaklodingenKB132_0504: 01-Jan-2005 - 01-Jan-2005 1
% 131 vaklodingenKB132_0706: 01-Jan-2005 - 01-Jan-2005 1
% 132 vaklodingenKB132_0908: 27-Mar-2000 - 12-Jun-2006 6
% 133 vaklodingenKB132_1110: 01-Jan-1927 - 15-Apr-2006 18
% 134 vaklodingenKB132_1312: 01-Jan-1927 - 03-Feb-2006 15
% 135 vaklodingenKB132_1514: 01-Jan-1927 - 01-Jan-1967 4
% 136 vaklodingenKB133_0504: 01-Jan-2005 - 01-Jan-2005 1
% 137 vaklodingenKB133_0706: 01-Jan-2005 - 01-Jan-2005 1
% 138 vaklodingenKB133_0908: 01-Jan-1985 - 08-Jun-2007 9
% 139 vaklodingenKB133_1110: 01-Jan-1927 - 08-Apr-2007 28
% 140 vaklodingenKB133_1312: 01-Jan-1927 - 07-Feb-2006 15
% 141 vaklodingenKB134_0504: 01-Jan-2005 - 01-Jan-2005 1
% 142 vaklodingenKB134_0706: 01-Jan-2005 - 01-Jan-2005 1
% 143 vaklodingenKB134_0908: 01-Jan-1985 - 19-Jun-2007 9
% 144 vaklodingenKB134_1110: 01-May-1983 - 04-May-2007 22
% 145 vaklodingenKB134_1312: 01-Jan-1985 - 04-May-2007 12
% 146 vaklodingenKB135_0504: 01-Jan-2005 - 01-Jan-2005 1
% 147 vaklodingenKB135_0706: 01-Jan-2005 - 01-Jan-2005 1
% 148 vaklodingenKB135_0908: 01-Jan-2001 - 19-Jun-2007 4
% 149 vaklodingenKB135_1110: 01-May-1983 - 04-May-2007 16
% 150 vaklodingenKB135_1312: 01-May-1983 - 04-May-2007 12
% 151 vaklodingenKB136_0504: 01-Jan-2005 - 01-Jan-2005 1
% 152 vaklodingenKB136_0706: 01-Jan-2005 - 01-Jan-2005 1
% 153 vaklodingenKB136_0908: 01-Jan-2005 - 01-Jan-2005 1
% 154 vaklodingenKB136_1110: 01-May-1983 - 01-Jan-2005 11
% 155 vaklodingenKB136_1312: 01-May-1983 - 01-Jan-2005 13
% 156 vaklodingenKB136_1514: 01-Jul-1983 - 01-Jan-2005 11
% 157 vaklodingenKB137_0504: 01-Jan-2005 - 01-Jan-2005 1
% 158 vaklodingenKB137_0706: 01-Jan-2005 - 01-Jan-2005 1
% 159 vaklodingenKB137_0908: 01-Jan-2005 - 01-Jan-2005 1
% 160 vaklodingenKB137_1110: 01-Jan-1985 - 01-Jan-2005 8
% 161 vaklodingenKB137_1312: 01-Jan-1985 - 01-Jan-2005 12
% 162 vaklodingenKB137_1514: 01-Nov-1983 - 01-Jan-2005 12
% 163 vaklodingenKB137_1716: 01-Jan-1985 - 01-Jan-2005 10
% 164 vaklodingenKB138_0504: 01-Jan-2005 - 01-Jan-2005 1
% 165 vaklodingenKB138_0706: 01-Jan-2005 - 01-Jan-2005 1
% 166 vaklodingenKB138_0908: 01-Jan-2005 - 01-Jan-2005 1
% 167 vaklodingenKB138_1110: 01-Jan-2005 - 01-Jan-2005 1
% 168 vaklodingenKB138_1514: 01-Jan-1985 - 01-Jan-2005 10
% 169 vaklodingenKB138_1716: 01-Jan-1985 - 01-Jan-2005 10
% 170 vaklodingenKB139_0504: 01-Jan-2005 - 01-Jan-2005 1
% 171 vaklodingenKB139_0706: 01-Jan-2005 - 01-Jan-2005 1
% 172 vaklodingenKB139_0908: 01-Jan-2005 - 01-Jan-2005 1
% 173 vaklodingenKB139_1514: 01-Jan-1985 - 01-Jan-2005 7
% 174 vaklodingenKB139_1716: 01-Jan-2005 - 01-Jan-2005 1
% 175 vaklodingenKB139_1918: 01-Jan-2005 - 01-Jan-2005 1
% 176 vaklodingenKB139_2120: 01-Jan-2005 - 01-Jan-2005 1
% 177 vaklodingenKB140_1716: 01-Jan-2005 - 01-Jan-2005 1