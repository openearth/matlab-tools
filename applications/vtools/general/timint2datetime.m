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
%Convert time input as integer number to datetime. 

function tim_dtime=timint2datetime(tim_int)

ntim=numel(tim_int);
tim_dtime=NaT(ntim,1);
tim_dtime.TimeZone='+00:00';

%There must be a way to do this nicer in vectorial form
for ktim=1:ntim
    tim_dtime(ktim)=datetime(num2str(tim_int(ktim)),'InputFormat','yyyyMMdd','TimeZone','+00:00');
end %ktim

end %function