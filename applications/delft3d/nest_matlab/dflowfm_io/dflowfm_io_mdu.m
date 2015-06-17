function varargout=dflowfm_io_mdu(cmd,varargin)

%DFLOWFM_IO_MDU  x read/write D-Dlow FM ASCII Master Definition File (*.mdu) <<beta version!>>
%
%  [DATA]        = unstruc_io_mdu('read' ,<filename>);
%
%                  unstruc_io_mdu('write',<filename>,mdu_structure);
%
%  [DATA]        = unstruc_io_mdu('new',<*.csv>)
%
% loads the template, this is a csv file with the mdu definition
%
% See also: delft3d_io_mdf

fname   = varargin{1};


%% Switch read/write/new

switch lower(cmd)

case 'read'
   simona2mdu_undress(fname,'scratch','comments',{'#' '*'});       %removes mdu cmments which dont belong in inifile
   [tmp       ] = inifile('open','scratch');
   delete 'scratch';

   %
   % Create one structure
   %

   for igroup = 1: size(tmp.Data,1)
       for ipar = 1:size(tmp.Data{igroup,2},1)
            grpnam = strtrim(tmp.Data{igroup,1});
            parnam = strtrim(tmp.Data{igroup,2}{ipar,1});

            %replace spaces by underscore

            grpnam = simona2mdu_replacechar(grpnam,' ','_');
            parnam = simona2mdu_replacechar(parnam,' ','_');

            % Fill mdu structure

            if ~isempty(str2num(tmp.Data{igroup,2}{ipar,2}))
                var = str2num(tmp.Data{igroup,2}{ipar,2});
            else
                var = tmp.Data{igroup,2}{ipar,2};
            end
            mdu.(grpnam).(parnam) = var;
       end
   end

   varargout  = {mdu};

case 'write'
   mdu          = varargin{2};
   mdu_Comments = varargin{3};

   %
   % Fill a temporary strucrure such hat it can be written by the function inifile
   %
   names  = fieldnames(mdu);
   maxlen = 0;

   for igroup= 1: length(names)
       tmp.Data{igroup,1} = simona2mdu_replacechar(names{igroup},'_',' ');
       pars = fieldnames(mdu.(names{igroup}));
       for ipar = 1: length(pars);
           tmp2{ipar,1} = simona2mdu_replacechar(pars{ipar},'_',' ');
           if  strcmpi(tmp2{ipar,1},'wall ks') tmp2{ipar,1} = simona2mdu_replacechar(tmp2{ipar,1},' ','_'); end
           if ~isempty(num2str(mdu.(names{igroup}).(pars{ipar})))
               line = num2str(mdu.(names{igroup}).(pars{ipar})) ;
           else
               line = mdu.(names{igroup}).(pars{ipar});
           end
           maxlen = max(maxlen,length(line) + 1);
%            line(40:c = ['# ' mdu_Comments.(names{igroup}).(pars{ipar})];
            tmp2{ipar,2} = line;
       end
       tmp.Data{igroup,2} = tmp2;
       clear tmp2
   end

   %% add comments
   for igroup = 1: length(names)
       pars = fieldnames(mdu.(names{igroup}));
       for ipar = 1: length(pars)
           line = tmp.Data{igroup,2}{ipar,2};
           while length(line) < maxlen + 4
               line(end + 1) = ' ';
           end
           line(maxlen + 5:maxlen + length(mdu_Comments.(names{igroup}).(pars{ipar})) + 6) = ...
           ['# ' mdu_Comments.(names{igroup}).(pars{ipar})];
           tmp.Data{igroup,2}{ipar,2} = line;
       end
   end

   inifile ('write',fname,tmp);

case 'new'
    %
    % Read csv file with mdu definition (used by GUI)
    % Replace space "external forcings" into underscore
    %
    tmp = simona2mdu_csvread(fname,'skiplines','*#');
    tmp(:,1) = simona2mdu_replacechar(tmp(:,1),' ','_');

    %
    % Get Groupnames
    %

    index_org = strncmpi('MduGroup',tmp(:,1),7);
    itel = 1;
    for i_ind = 1 : length(index_org)
        if index_org(i_ind) == 1
            index(itel) = i_ind;
            itel        = itel + 1;
        end
    end

    for igrp = index(1) + 1: index(2) - 1
        grpnam{igrp - index(1)} = tmp{igrp,1};
    end

    %
    % Get parameter names and their values and put in the mdu struct
    %

    for irow = index(2) + 1: size(tmp,1)
        for igrp = 1: length(grpnam)
            if strcmp(tmp{irow,1},grpnam{igrp})
                if ischar(tmp{irow,6})
                    if strcmpi(tmp{irow,6},'true')  tmp{irow,6} = 1;end
                    if strcmpi(tmp{irow,6},'false') tmp{irow,6} = 0;end
                end
                mdu.(grpnam{igrp}).(tmp{irow,2}) = tmp{irow,6};
                comment = '';
                for icol = 15: size(tmp,2)
                    if ~isempty (tmp{irow,icol})
                        comment = [comment ', ' tmp{irow,icol}];
                    end
                end
                mdu_Comment.(grpnam{igrp}).(tmp{irow,2}) = strtrim(comment(2:end));
            end
        end
    end

    varargout = {mdu,mdu_Comment};

end

