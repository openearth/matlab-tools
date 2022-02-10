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
%   -simdef.tra.IFORM = sediment transport flag [integer(1,1)] e.g. [4]
%   -simdef.tra.sedTrans = sediment transport parameters (as in ECT)
%
%OUTPUT:
%   -a .tra file compatible with D3D is created in file_name

%150728->151030
%   -addition of Ashida-Michiue and Wilcock-Crowe
%
%200526
%   -addition Engelund-Hansen and modification file

function D3D_tra(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;


%% RENAME

% dire_sim=simdef.D3D.dire_sim;
file_name=simdef.file.tra;
IFORM=simdef.tra.IFORM;
sedTrans=simdef.tra.sedTrans;

%% FILE

data{1  ,1}=sprintf('%d    IFORM',IFORM);

switch IFORM
    case 1
    data{2  ,1}=sprintf('#%d    EH',IFORM);
    data{3  ,1}=sprintf('%5.3f',sedTrans(1));
    data{4  ,1}=        '999';
    case 2
    data{2  ,1}=sprintf('#%d    MPM',IFORM);
    data{3  ,1}=        '%1';
    data{8  ,1}=        '999.999';
    case 4 
    data{2  ,1}=sprintf('#%d    GENERAL',IFORM);
    data{3  ,1}=sprintf('%5.3f',sedTrans(1));
    data{4  ,1}=        '0.0';
    data{5  ,1}=sprintf('%5.3f',sedTrans(2));
    data{6  ,1}=        '1.0';
    data{7  ,1}=sprintf('%5.3f',sedTrans(3));
    data{8  ,1}=        '999.999';
    case 14 
    data{2  ,1}=sprintf('#%d    AM',IFORM);
    data{3  ,1}=sprintf('%5.3f',sedTrans(1)); %alpha (a_am)
    data{4  ,1}=sprintf('%5.3f',sedTrans(2)); %theta_c  
    data{5  ,1}=        '1.5';                %m
    data{6  ,1}=        '1.0';                %p  
    data{7  ,1}=        '1.0';                %q   
    case 16
    data{2  ,1}=sprintf('#%d    WC',IFORM);   
end

%% WRITE

% file_name=fullfile(dire_sim,'tra.tra');
writetxt(file_name,data,'check_existing',check_existing);

end %function