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
%get absolute limits

function month_num=month_dutch2num(month_dutch)

switch lower(month_dutch)
    case 'januari'
        month_num=1;
    case 'februari'
        month_num=2;
    case 'maart'
        month_num=3;
    case 'april'
        month_num=4;
    case 'mei'
        month_num=5;
    case 'juni'
        month_num=6;
    case 'juli'
        month_num=7;
    case 'augustus'
        month_num=8;
    case 'september'
        month_num=9;
    case 'oktober'
        month_num=10;
    case 'november'
        month_num=11;
    case 'december'
        month_num=12;
    otherwise
        error('unknown month name')
end

end %function