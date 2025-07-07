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
%Convert any type of time to datetime

function tim_dtime=time2datetime(tim_in)

if isnumeric(tim_in)
    %Assume it is of type yyyymmdd
    tim_dtime=timint2datetime(tim_in);
elseif ischar(tim_in)
    try 
        tim_dtime=datetime(tim_in,'TimeZone','UTC');
    catch err
        tim_dtime=try_parse_datetime(tim_in);
    end
    if isnat(tim_dtime)
        error('Cannot process string: %s',tim_in)
    end
else
    error('Unknown type')
end

end

%%
%% FUNCTIONS
%%

function tim_dtime=try_parse_datetime(str)
    formats = {
        'yyyy-MM-dd''T''HH:mm:ssZ',       
        'yyyy-MM-dd''T''HH:mm:ssXXX',     
        'yyyy-MM-dd HH:mm:ss',            
        'MM/dd/yyyy HH:mm:ss',            
        'dd-MM-yyyy HH:mm:ss',            
        'dd/MM/yyyy HH:mm:ss',            
        'yyyyMMdd''T''HHmmss',            
        'yyyy-MM-dd',                     
        'MM/dd/yyyy',                     
        'dd-MM-yyyy',                     
        'HH:mm:ss'                        
    };

    tim_dtime = NaT;  % Default result
    for i = 1:length(formats)
        try
            tim_dtime = datetime(str, 'InputFormat', formats{i},'TimeZone','UTC');
            if ~isnat(tim_dtime)
                return;  % Success
            end
        catch
            % Try next format
        end
    end
end %function