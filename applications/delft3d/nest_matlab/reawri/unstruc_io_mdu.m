function varargout=unstruc_io_mdu(cmd,varargin),

%UNSTRUC_IO_MDU  x read/write UNSTRUC ASCII Master Definition File (*.mdu) <<beta version!>>
%
%  [DATA]        = unstruc_io_mdu('read' ,<filename>,mdu_structure);
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
   delete('scratch');

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

            mdu.(grpnam).(parnam) = tmp.Data{igroup,2}{ipar,2};
       end
   end

   varargout  = {mdu};

case 'write'
   mdu = varargin{2};
   %
   % Fill a temporary strucrure such hat it can be written by the function inifile
   %
   names = fieldnames(mdu);
   
   for igroup= 1: length(names)
       tmp.Data{igroup,1} = names{igroup};
       pars = fieldnames(mdu.(names{igroup}));
       for ipar = 1: length(pars);
           tmp2{ipar,1} = pars{ipar};
           tmp2{ipar,2} = mdu.(names{igroup}).(pars{ipar});
       end
       tmp.Data{igroup,2} = tmp2;
       clear tmp2
   end

   inifile ('write',fname,tmp);

case 'new'
    tmp = simona2mdu_csvread(fname);
end
