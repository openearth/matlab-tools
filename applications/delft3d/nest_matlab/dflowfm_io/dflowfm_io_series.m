function varargout=dflowfm_io_series(cmd,varargin)

%  DFLOWFM_IO_series  read/write D-Flow FM (time) series file
%
%  [SERIES]           = dflowfm_io_series('read' ,<filename>);
%
%                       dflowfm_io_series('write',<filename>,SERIES)
%
% See also: dflowfm_io_mdu

fname     = varargin{1};

%% Switch read/write

switch lower(cmd)

   case 'read'
      SERIES = [];
      i_comm = 0;
      i_row  = 0;
     
      %% Open File
      fid = fopen(fname,'r');
      while ~feof(fid)
          tline = strtrim(fgetl(fid));
          if ~isempty(tline)
              if strcmp(tline(1),'*')
                  
                  %% Read comment lines
                  i_comm = i_comm + 1;
                  SERIES.Comments{i_comm} = strtrim(tline);
              else
                  
                  %% Read the values (as long as you can find numbers!)
                  i_col = 0;
                  i_row = i_row + 1;
                  index = d3d2dflowfm_decomposestr(tline);
                  for i_val = 1: length(index) - 1
                      value = str2num(tline(index(i_val):index(i_val+1) - 1));
                      if ~isempty(value)
                          i_col = i_col + 1;
                          SERIES.Values(i_row,i_col) = value;
                      else
                          break
                      end
                  end
              end
          end
      end
      
      %% Close the file and assign SERIES
      fclose (fid);
      varargout{1} = SERIES;

   case 'write'
      %
      % Get comments and series
      Comments = '';
      Values   = [];

      SERIES = varargin{2};

      if isfield(SERIES,'Comments')
         Comments = SERIES.Comments;
      end
      if isfield(SERIES,'Values')
         Values = SERIES.Values;
      end

      %
      % Open file
      fid  =  fopen(fname,'w+');

      %
      % Write Comments to file (if present)
      if ~isempty(Comments)
         for i_comm = 1: length(Comments)
             fprintf(fid,'%s  \n',Comments{i_comm});
         end
      end

      %
      % Write values to file
      if ~isempty(Values)
          n_rows = size(Values,1);
          n_cols = size(Values,2);
          format = '%12.3f ';
          format = [format repmat('%12.6f ',1,n_cols - 1) '\n'];

          for i_row = 1:n_rows
             fprintf(fid,format,Values(i_row,:));
          end
      end
      
      fclose(fid);
end
