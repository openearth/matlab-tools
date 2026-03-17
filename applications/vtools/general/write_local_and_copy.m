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
%E.G.
% [fid,fname_local]=write_local_and_copy('open',fname_destiny,'overwrite',false);
% fprintf(fid,'...')
% write_local_and_copy('close',fid,fname_local,fname_destiny)


function [varargout]=write_local_and_copy(method,varargin)

%% CALC

switch method
    case 'open'
        fname_destiny=varargin{1};

        parin=inputParser;

        addOptional(parin,'overwrite',false)

        parse(parin,varargin{2:end})

        overwrite=parin.Results.overwrite;

        fname_local=fullfile(pwd,now_chr);
        %check if the file already exists
        if ~overwrite && exist(fname_destiny,'file')>0
            error('You are trying to overwrite a file!')
        end
        fid=fopen(fname_local,'w');
        if fid==-1
            error('Could not open file for writing: %s',fname_local)
        end

        varargout{1} = fid;
        varargout{2} = fname_local;
    case 'close'
        fid=varargin{1};
        fname_local=varargin{2};
        fname_destiny=varargin{3};

        fclose(fid);
        copyfile_check(fname_local,fname_destiny);
        delete(fname_local);
    otherwise
        error('Unknown method: %s',method)
end

end %function