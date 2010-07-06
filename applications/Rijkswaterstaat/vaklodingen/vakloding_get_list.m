function vakloding_get_list(url)
%VAKLODING_GET_LIST  list of all kaartbladen and all times from opendap server
%
% vakloding_get_list(url)
%
% Example:
%
%    vakloding_get_list('http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml')
%    vakloding_get_list('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml')
%
%See also: rijkswaterstaat

L = opendap_catalog(url);

for i=1:length(L)
t = nc_cf_time(L{i},'time');
disp([num2str(i,'%0.3d'),' ',pad(filename(L{i}),' ',-21),': ',datestr(t(1)),' - ',datestr(t(end)),' ',num2str(length(t))])
end

% http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml: 2010-jul-6
% 001 vaklodingenKB129_1312: 01-Jan-1926 - 17-Mar-2005 22
% 002 vaklodingenKB113_4544: 01-Jan-1960 - 09-Mar-2007 24
% 003 vaklodingenKB124_1312: 01-Jan-1926 - 07-Aug-2002 10
% 004 vaklodingenKB117_3534: 01-Apr-1993 - 06-Aug-2008 5
% 005 vaklodingenKB115_4544: 01-Jan-1960 - 09-Mar-2007 29
% 006 vaklodingenKB126_1514: 01-Jan-1926 - 11-Feb-2004 10
% 007 vaklodingenKB131_1514: 01-Jan-1927 - 01-Jan-1967 4
% 008 vaklodingenKB117_3736: 01-Jan-1964 - 11-Sep-2006 15
% 009 vaklodingenKB111_5150: 01-Jan-1968 - 08-Jul-2003 27
% 010 vaklodingenKB118_3938: 01-Jan-1964 - 01-May-2008 8
% 011 vaklodingenKB139_1716: 01-Jan-2005 - 01-Jan-2005 1
% 012 vaklodingenKB131_1110: 01-Jan-1927 - 17-Mar-2005 16
% 013 vaklodingenKB137_0706: 01-Jan-2005 - 01-Jan-2005 1
% 014 vaklodingenKB117_5150: 01-Jan-1951 - 13-Aug-2008 40
% 015 vaklodingenKB120_3332: 01-Apr-1990 - 31-Mar-2008 9
% 016 vaklodingenKB119_2726: 05-Mar-2001 - 20-Jun-2005 2
% 017 vaklodingenKB123_2322: 01-Jan-1926 - 13-Mar-2003 9
% 018 vaklodingenKB135_0706: 01-Jan-2005 - 01-Jan-2005 1
% 019 vaklodingenKB109_4948: 01-Jan-1976 - 01-Jan-2003 20
% 020 vaklodingenKB136_1110: 01-May-1983 - 01-Jan-2005 11
% 021 vaklodingenKB127_1312: 01-Jan-1926 - 25-May-2004 13
% 022 vaklodingenKB137_1514: 01-Nov-1983 - 01-Jan-2005 12
% 023 vaklodingenKB126_1312: 01-Jan-1926 - 25-May-2004 14
% 024 vaklodingenKB128_1110: 01-Jan-1926 - 22-Mar-2005 10
% 025 vaklodingenKB118_5150: 01-Jan-1951 - 10-Aug-2008 59
% 026 vaklodingenKB125_1110: 01-Apr-1998 - 27-Sep-2000 2
% 027 vaklodingenKB123_1312: 01-Aug-1992 - 07-Aug-2002 5
% 028 vaklodingenKB112_4342: 01-Jan-1989 - 22-Jun-2007 9
% 029 vaklodingenKB117_4746: 01-Jan-1986 - 21-Dec-2006 10
% 030 vaklodingenKB111_4948: 01-Jan-1964 - 01-Jan-2003 29
% 031 vaklodingenKB138_0908: 01-Jan-2005 - 01-Jan-2005 1
% 032 vaklodingenKB132_0706: 01-Jan-2005 - 01-Jan-2005 1
% 033 vaklodingenKB114_4140: 01-Jan-1960 - 16-Aug-2006 20
% 034 vaklodingenKB137_1312: 01-Jan-1985 - 01-Jan-2005 12
% 035 vaklodingenKB122_1716: 01-Jan-1926 - 26-Jul-2006 17
% 036 vaklodingenKB115_5150: 01-Jan-1955 - 02-Oct-2008 32
% 037 vaklodingenKB139_1918: 01-Jan-2005 - 01-Jan-2005 1
% 038 vaklodingenKB119_2928: 05-Mar-2001 - 16-Aug-2008 3
% 039 vaklodingenKB114_4746: 23-Apr-2002 - 14-Apr-2008 3
% 040 vaklodingenKB124_2322: 01-Sep-1985 - 11-Mar-2003 2
% 041 vaklodingenKB125_1514: 01-Jan-1926 - 11-Feb-2004 11
% 042 vaklodingenKB121_3130: 01-Apr-1990 - 24-Apr-2005 5
% 043 vaklodingenKB116_4544: 01-Jan-1986 - 21-Dec-2006 12
% 044 vaklodingenKB120_2726: 01-Dec-1987 - 09-Apr-2008 8
% 045 vaklodingenKB135_0908: 01-Jan-2001 - 19-Jun-2007 4
% 046 vaklodingenKB139_2120: 01-Jan-2005 - 01-Jan-2005 1
% 047 vaklodingenKB121_2726: 01-May-1987 - 09-Apr-2008 8
% 048 vaklodingenKB113_4948: 01-Jan-1950 - 25-Apr-2007 36
% 049 vaklodingenKB123_1918: 01-Jan-1926 - 14-Jan-2003 13
% 050 vaklodingenKB119_4544: 01-Jan-1992 - 25-Feb-2007 4
% 051 vaklodingenKB125_1918: 01-Jan-1926 - 16-Apr-2003 11
% 052 vaklodingenKB125_1716: 01-Jan-1926 - 01-Jul-2003 9
% 053 vaklodingenKB111_4544: 01-Jan-1964 - 22-Jan-2001 21
% 054 vaklodingenKB138_1110: 01-Jan-2005 - 01-Jan-2005 1
% 055 vaklodingenKB115_4948: 01-Jan-1955 - 02-Oct-2008 32
% 056 vaklodingenKB135_0504: 01-Jan-2005 - 01-Jan-2005 1
% 057 vaklodingenKB120_3534: 01-Apr-1990 - 07-May-2008 6
% 058 vaklodingenKB139_0706: 01-Jan-2005 - 01-Jan-2005 1
% 059 vaklodingenKB122_2322: 01-Jan-1926 - 05-Mar-2001 11
% 060 vaklodingenKB114_4342: 01-Jan-1960 - 09-Mar-2007 34
% 061 vaklodingenKB134_0504: 01-Jan-2005 - 01-Jan-2005 1
% 062 vaklodingenKB115_4746: 01-Jan-2001 - 14-Apr-2008 4
% 063 vaklodingenKB115_3736: 01-Jan-1989 - 01-Jan-1989 1
% 064 vaklodingenKB117_3938: 01-Jan-1964 - 11-Sep-2006 31
% 065 vaklodingenKB110_4746: 01-Jan-1964 - 01-Jan-2003 30
% 066 vaklodingenKB119_3736: 01-Apr-1990 - 10-May-2008 6
% 067 vaklodingenKB134_0908: 01-Jan-1985 - 19-Jun-2007 9
% 068 vaklodingenKB121_1918: 01-Jan-1926 - 21-Apr-2005 11
% 069 vaklodingenKB120_2928: 01-Sep-1990 - 18-Feb-2008 7
% 070 vaklodingenKB121_1716: 01-Jan-1926 - 26-Jul-2006 16
% 071 vaklodingenKB128_1312: 01-Jan-1926 - 07-Mar-2005 11
% 072 vaklodingenKB123_1514: 01-Jan-1926 - 07-Aug-2007 17
% 073 vaklodingenKB120_3130: 01-Apr-1990 - 18-Feb-2008 7
% 074 vaklodingenKB133_0504: 01-Jan-2005 - 01-Jan-2005 1
% 075 vaklodingenKB138_0504: 01-Jan-2005 - 01-Jan-2005 1
% 076 vaklodingenKB136_0504: 01-Jan-2005 - 01-Jan-2005 1
% 077 vaklodingenKB128_1514: 01-Jan-1926 - 21-Jun-2004 9
% 078 vaklodingenKB111_4746: 01-Jan-1964 - 01-Jan-2003 34
% 079 vaklodingenKB124_1514: 01-Jan-1926 - 01-Apr-2005 13
% 080 vaklodingenKB122_1918: 01-Jan-1926 - 21-Apr-2005 15
% 081 vaklodingenKB112_4948: 01-Jan-1960 - 07-Sep-2005 42
% 082 vaklodingenKB132_1110: 01-Jan-1927 - 15-Apr-2006 18
% 083 vaklodingenKB133_1110: 01-Jan-1927 - 08-Apr-2007 28
% 084 vaklodingenKB132_0504: 01-Jan-2005 - 01-Jan-2005 1
% 085 vaklodingenKB119_3534: 01-Apr-1990 - 07-May-2008 6
% 086 vaklodingenKB139_0504: 01-Jan-2005 - 01-Jan-2005 1
% 087 vaklodingenKB124_1716: 01-Jan-1926 - 02-Jul-2003 14
% 088 vaklodingenKB137_0504: 01-Jan-2005 - 01-Jan-2005 1
% 089 vaklodingenKB126_1716: 01-Jan-1926 - 01-Jul-2003 10
% 090 vaklodingenKB115_3938: 01-Jan-1964 - 04-Aug-2004 14
% 091 vaklodingenKB139_0908: 01-Jan-2005 - 01-Jan-2005 1
% 092 vaklodingenKB132_1312: 01-Jan-1927 - 03-Feb-2006 15
% 093 vaklodingenKB119_3130: 01-Dec-1996 - 31-Mar-2008 5
% 094 vaklodingenKB118_4948: 01-Jan-1951 - 10-Aug-2008 61
% 095 vaklodingenKB120_2524: 01-Oct-1987 - 10-Apr-2008 7
% 096 vaklodingenKB113_4342: 01-Jan-1960 - 14-Jun-2007 19
% 097 vaklodingenKB116_4342: 01-Jan-1964 - 16-Aug-2006 25
% 098 vaklodingenKB136_1312: 01-May-1983 - 01-Jan-2005 13
% 099 vaklodingenKB118_4140: 01-Jan-1957 - 01-Jan-1957 1
% 100 vaklodingenKB138_1514: 01-Jan-1985 - 01-Jan-2005 10
% 101 vaklodingenKB131_1312: 01-Jan-1927 - 16-Jan-2006 15
% 102 vaklodingenKB130_1312: 01-Jan-1927 - 17-Mar-2005 17
% 103 vaklodingenKB127_1716: 01-Jan-1926 - 01-Jul-2003 9
% 104 vaklodingenKB125_2120: 01-Jan-1926 - 02-Jul-2003 10
% 105 vaklodingenKB132_0908: 27-Mar-2000 - 12-Jun-2006 6
% 106 vaklodingenKB119_2524: 05-Mar-2001 - 05-Mar-2001 1
% 107 vaklodingenKB127_1514: 01-Jan-1926 - 25-May-2004 13
% 108 vaklodingenKB137_0908: 01-Jan-2005 - 01-Jan-2005 1
% 109 vaklodingenKB125_1312: 01-Jan-1926 - 25-Mar-2004 10
% 110 vaklodingenKB140_1716: 01-Jan-2005 - 01-Jan-2005 1
% 111 vaklodingenKB137_1110: 01-Jan-1985 - 01-Jan-2005 8
% 112 vaklodingenKB133_0706: 01-Jan-2005 - 01-Jan-2005 1
% 113 vaklodingenKB118_4746: 01-Jan-1988 - 30-Jan-2007 9
% 114 vaklodingenKB123_1716: 01-Jan-1926 - 26-Jul-2006 15
% 115 vaklodingenKB121_2322: 01-Jan-1926 - 19-Apr-2008 18
% 116 vaklodingenKB114_5150: 01-Jan-1955 - 15-Oct-2008 31
% 117 vaklodingenKB134_1312: 01-Jan-1985 - 04-May-2007 12
% 118 vaklodingenKB110_4948: 01-Jan-1968 - 01-Jan-2003 29
% 119 vaklodingenKB126_1110: 01-Jan-1926 - 01-Jul-2004 10
% 120 vaklodingenKB116_4140: 01-Jan-1957 - 01-Jan-2004 28
% 121 vaklodingenKB116_3736: 01-Jan-1989 - 11-Sep-2006 10
% 122 vaklodingenKB115_4342: 01-Jan-1960 - 08-Nov-2007 32
% 123 vaklodingenKB133_1312: 01-Jan-1927 - 07-Feb-2006 15
% 124 vaklodingenKB118_3534: 01-May-1990 - 10-May-2008 6
% 125 vaklodingenKB130_1514: 01-Jan-1927 - 01-Jan-1958 2
% 126 vaklodingenKB118_2928: 05-Mar-2001 - 05-Mar-2001 1
% 127 vaklodingenKB120_2120: 01-Jan-1926 - 13-Feb-2006 8
% 128 vaklodingenKB134_0706: 01-Jan-2005 - 01-Jan-2005 1
% 129 vaklodingenKB117_4544: 01-Jan-1986 - 26-Feb-2007 11
% 130 vaklodingenKB133_0908: 01-Jan-1985 - 08-Jun-2007 9
% 131 vaklodingenKB121_2928: 01-Apr-1990 - 18-Feb-2008 7
% 132 vaklodingenKB136_1514: 01-Jul-1983 - 01-Jan-2005 11
% 133 vaklodingenKB121_2524: 01-May-1987 - 10-Apr-2008 8
% 134 vaklodingenKB115_4140: 01-Jan-1964 - 07-Aug-2006 29
% 135 vaklodingenKB114_4544: 01-Jan-1960 - 14-Apr-2008 34
% 136 vaklodingenKB120_2322: 01-Jan-1926 - 19-Apr-2008 14
% 137 vaklodingenKB129_1110: 01-Jan-1926 - 13-Apr-2005 13
% 138 vaklodingenKB135_1110: 01-May-1983 - 04-May-2007 16
% 139 vaklodingenKB122_2120: 01-Jan-1926 - 13-Feb-2006 14
% 140 vaklodingenKB132_1514: 01-Jan-1927 - 01-Jan-1967 4
% 141 vaklodingenKB110_5150: 01-Jan-1968 - 09-Sep-2003 28
% 142 vaklodingenKB112_4544: 01-Jan-1960 - 09-Jan-2006 36
% 143 vaklodingenKB113_4746: 01-Jan-1960 - 07-Sep-2005 35
% 144 vaklodingenKB109_5150: 01-Jan-1976 - 02-Oct-2003 20
% 145 vaklodingenKB118_3736: 01-Jan-1964 - 01-May-2008 8
% 146 vaklodingenKB124_2120: 01-Jan-1926 - 27-Jan-2003 10
% 147 vaklodingenKB119_3332: 01-May-1990 - 31-Mar-2008 8
% 148 vaklodingenKB112_4746: 01-Jan-1960 - 07-Sep-2005 46
% 149 vaklodingenKB137_1716: 01-Jan-1985 - 01-Jan-2005 10
% 150 vaklodingenKB116_4948: 01-Jan-1955 - 20-Aug-2008 59
% 151 vaklodingenKB118_4544: 01-Jan-1986 - 04-Mar-2007 11
% 152 vaklodingenKB126_1918: 01-Jan-1926 - 01-Jul-2003 10
% 153 vaklodingenKB122_1514: 01-Jan-1926 - 20-Aug-2007 13
% 154 vaklodingenKB114_4948: 01-Jan-1950 - 26-Apr-2007 37
% 155 vaklodingenKB116_3938: 01-Jan-1957 - 11-Sep-2006 31
% 156 vaklodingenKB131_0908: 02-Apr-2001 - 19-Apr-2006 3
% 157 vaklodingenKB118_3332: 01-Aug-1997 - 07-Aug-2008 4
% 158 vaklodingenKB134_1110: 01-May-1983 - 04-May-2007 22
% 159 vaklodingenKB138_1716: 01-Jan-1985 - 01-Jan-2005 10
% 160 vaklodingenKB121_2120: 01-Jan-1926 - 13-Feb-2006 13
% 161 vaklodingenKB114_3938: 01-Jan-1989 - 01-Jan-1989 1
% 162 vaklodingenKB135_1312: 01-May-1983 - 04-May-2007 12
% 163 vaklodingenKB120_1918: 01-Jan-1926 - 07-Jul-2006 7
% 164 vaklodingenKB116_4746: 01-Jan-1973 - 21-Dec-2006 13
% 165 vaklodingenKB124_1918: 01-Jan-1926 - 22-Jan-2003 15
% 166 vaklodingenKB136_0908: 01-Jan-2005 - 01-Jan-2005 1
% 167 vaklodingenKB116_5150: 01-Jan-1955 - 20-Aug-2008 31
% 168 vaklodingenKB136_0706: 01-Jan-2005 - 01-Jan-2005 1
% 169 vaklodingenKB117_4140: 01-Jan-1957 - 17-Mar-2004 27
% 170 vaklodingenKB127_1110: 01-Jan-1926 - 01-Jul-2004 10
% 171 vaklodingenKB139_1514: 01-Jan-1985 - 01-Jan-2005 7
% 172 vaklodingenKB129_1514: 01-Jan-1926 - 07-Mar-2005 12
% 173 vaklodingenKB130_1110: 01-Jan-1927 - 20-Apr-2005 18
% 174 vaklodingenKB138_0706: 01-Jan-2005 - 01-Jan-2005 1
% 175 vaklodingenKB117_4948: 01-Jan-1951 - 12-Aug-2008 65
% 176 vaklodingenKB118_3130: 05-Mar-2001 - 16-Aug-2008 5
% 177 vaklodingenKB123_2120: 01-Jan-1926 - 27-Jan-2003 10
