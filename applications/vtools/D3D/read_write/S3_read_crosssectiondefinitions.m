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
%Reads:
%   -cross section definition file Sobek3
%   -cross section definition file FM
%   -cross section location file FM
%
%INPUT
%   -path_csloc = path to the file to read
%
%OUPUT
%   -csloc_in = raw ascii read of cross-sections-location file; cell(nl,1); nl=number of lines of file
%   -cs       = structure of cross-sections-location; struct
%
%OPTIONAL 
%   -'file_type' = type of file: 
%       1=cross section definition file Sobek3; 
%       2=cross section definition file FM
%       3=cross section location file FM


function [csloc_in,cs]=S3_read_crosssectiondefinitions(path_csloc,varargin)

%% PARSE

parin=inputParser;
addOptional(parin,'file_type',1);
parse(parin,varargin{:});
file_type=parin.Results.file_type;

%% FM or SOBEK3

%fcnts = function to apply to the string we get:
%    1 = get the string
%    2 = convert to double
%    3 = convert to double and make integer (take only number before .)

str_dec='[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)';
str_char_one='\w+([.-]?\w+)*';
str_char_list='\w+([.-]?\w+)*(;\w+([.-]?\w+)*)*';

switch file_type
    case 1 %SOBEK 3 cross-section definition
        tag_cs='[CrossSection]';
        specs={ ...
            'id'        ,str_char_one                 ,@parse_first ; ...
            'branchid'  ,str_char_one                 ,@parse_first ; ...
            'chainage'  ,str_dec             ,@parse_double; ...
            'name'      ,str_char_one                 ,@parse_first ; ...
            'shift'     ,str_dec             ,@parse_double; ...
            'definition',str_char_one                 ,@parse_first ; ...
        };
    case 2 %FM cross-section definition zw
        tag_cs='[Definition]';
        specs={ ...
            'id'              ,str_char_one                 ,@parse_first  ; ...
            'type'            ,str_char_one                 ,@parse_first  ; ...
            'thalweg'         ,str_dec             ,@parse_double ; ...
            'numLevels'       ,'\d+'               ,@parse_integer; ...
            'levels'          ,str_dec             ,@parse_double ; ...
            'flowWidths'      ,str_dec             ,@parse_double ; ...
            'totalWidths'     ,str_dec             ,@parse_double ; ...
            'leveeCrestLevel' ,str_dec             ,@parse_double ; ...
            'leveeFlowArea'   ,str_dec             ,@parse_double ; ...
            'leveeTotalArea'  ,str_dec             ,@parse_double ; ...
            'leveeBaseLevel'  ,str_dec             ,@parse_double ; ...
            'mainWidth'       ,str_dec             ,@parse_double ; ...
            'fp1Width'        ,str_dec             ,@parse_double ; ...
            'fp2Width'        ,str_dec             ,@parse_double ; ...
            'isShared'        ,'\d+'               ,@parse_double ; ...
            'frictionIds'     ,str_char_list                ,@parse_first  ; ...
        };
    case 3 %FM cross-section location  
        tag_cs='[CrossSection]';
        specs={ ...
            'id'          ,str_char_one                 ,@parse_first ; ...
            'branchId'    ,str_char_one                 ,@parse_first ; ...
            'chainage'    ,str_dec             ,@parse_double; ...
            'shift'       ,str_dec             ,@parse_double; ...
            'definitionId',str_char_one                 ,@parse_first ; ...
        };
    case 4 %FM cross-section definition xyz
        tag_cs='[Definition]';
        specs={ ...
            'id'          ,str_char_one                 ,@parse_first ; ...
            'type'        ,str_char_one                 ,@parse_first ; ...
            'thalweg'     ,str_dec             ,@parse_double; ...
            'xyzCount'    ,'\d+'               ,@parse_double; ...
            'xCoordinates',str_dec             ,@parse_double; ...
            'yCoordinates',str_dec             ,@parse_double; ...
            'zCoordinates',str_dec             ,@parse_double; ...
            'conveyance'  ,str_char_one                 ,@parse_first ; ...
            'sectionCount','\d+'               ,@parse_double; ...
            'frictionIds' ,str_char_list                ,@parse_first ; ...
        };
    case 5 %FM cross-section definition yz
        tag_cs='[Definition]';
        specs={ ...
            'id'          ,str_char_one                 ,@parse_first ; ...
            'type'        ,str_char_one                 ,@parse_first ; ...
            'thalweg'     ,str_dec             ,@parse_double; ...
            'yzCount'     ,'\d+'               ,@parse_double; ...
            'yCoordinates',str_dec             ,@parse_double; ...
            'zCoordinates',str_dec             ,@parse_double; ...
            'conveyance'  ,str_char_one                 ,@parse_first ; ...
            'sectionCount','\d+'               ,@parse_double; ...
            'frictionIds' ,str_char_list                ,@parse_first ; ...
        };
    case 6 %FM cross-section definition rectangle
        tag_cs='[Definition]';
        specs={ ...
            'id'     ,str_char_one                 ,@parse_first ; ...
            'type'   ,str_char_one                 ,@parse_first ; ...
            'thalweg',str_dec             ,@parse_double; ...
            'width'  ,str_dec             ,@parse_double; ...
            'height' ,str_dec             ,@parse_double; ...
            'closed' ,str_char_one                 ,@parse_first ; ...
        };
    case 7 %Global block
        tag_cs='[Global]';
        specs={ ...
            'leveeTransitionHeight',str_dec             ,@parse_double; ...
        };
end

ntags=size(specs,1);

%%
csloc_in=read_ascii(path_csloc);

nlcsin=numel(csloc_in);
cs=struct();
kcs=1;
for kl=1:nlcsin
    str_loc=csloc_in{kl,1};
    if contains(str_loc,tag_cs)
        kl2=kl+1;
        str_loc2=csloc_in{kl2,1};
        go=true;
        while go
            str_aux_r=regexp(str_loc2,'\w+','match');
            if ~isempty(str_aux_r)
                tag_loc2=str_aux_r{1,1};
                for ktags=1:ntags
                    if strcmpi(tag_loc2,specs{ktags,1})
                        %take part after the equal
                        str_aux_split=regexp(str_loc2,'=','split');
                        if numel(str_aux_split)~=2
                            error('One equal sign (''='') is expected in: %s',str_loc2)
                        end
                        str_value=str_aux_split{2};
                        str_aux_l3=regexp(str_value,specs{ktags,2},'match');
                        strconv=specs{ktags,3}(str_aux_l3);
                        cs(kcs).(specs{ktags,1})=strconv;
                    end
                end
            end
            %next line
            kl2=kl2+1;

            if kl2>nlcsin
                go=false;
            else
                %check if already next block
                str_loc2=csloc_in{kl2,1};
                if contains(str_loc2,tag_cs)
                    go=false;
                end
            end
        end
        %update cross-section counter
        kcs=kcs+1;
    end
end

end %function

%%
function strconv=parse_first(str_aux_r)

strconv=str_aux_r{1,1};

end %parse_first

function strconv=parse_double(str_aux_r)

strconv=str2double(str_aux_r);

end %parse_double

function strconv=parse_integer(str_aux_r)

strconv=str2double(str_aux_r);
if numel(strconv)>1
    strconv=strconv(1);
end

end %parse_integer