function varargout=unstruc_io_xydata(cmd,varargin)

%UNSTRUC_IO_xydata  read/write UNSTRUC xy file or xy data file where data cab be a number (depth, viscosity etc) or
%                   a string (a station name)
%
%  [LINE]        = unstruc_io_mdu('read' ,<filename>);
%
%                  unstruc_io_mdu('write',<filename>,LINE);
%
%   LINE(1).DATA{:,3}  contains x-coordinate, y-coordinate and z-value or string (stationname for instance)
%   LINE(:).Blckname   contains blockname (for instance the name of the crosssection or simply LINE in case of a thindam)
%
% See also: unstruc_io_mdu

fname   = varargin{1};


%% Switch read/write/new

switch lower(cmd)

case 'read'

   %
   %  to implement yet
   %

case 'write'

   fid  =  fopen(fname,'w+');
   LINE = varargin{2};

   for iline = 1: length(LINE)
    
       nrows      = size(LINE(iline).DATA,1);
       ncols      = size(LINE(iline).DATA,2);
       
       if isfield(LINE(iline),'Blckname')
           
          %Blockname specified, write blockname, nrows, ncols 
          block_name = LINE(iline).Blckname;
          
          fprintf(fid,'%s       \n',block_name      );
          fprintf(fid,'%5i  %5i \n',nrows     ,ncols);
       end
       
       if size(LINE(iline).DATA,2) == 3
          
           % xyz or xy string data
           if ischar(LINE(iline).DATA{1,3})

               % xy string data (stations for example
               for irow = 1: size(LINE(iline).DATA,1)
                   fprintf(fid,'%14.8e %14.8e %s \n',LINE(iline).DATA{irow,1},LINE(iline).DATA{irow,2},LINE(iline).DATA{irow,3});
               end
           else

               % xyz data
               for irow = 1: size(LINE(iline).DATA,1)
                   fprintf(fid,'%14.8e %14.8e %14.8e \n',LINE(iline).DATA{irow,1},LINE(iline).DATA{irow,2},LINE(iline).DATA{irow,3});
               end
           end
       else
           
           % only x and y values
           for icol = 1: nrows
              fprintf(fid,'%14.6e  %14.6e  \n',LINE(iline).DATA{icol,1},LINE(iline).DATA{icol,2});
           end
       end
   end
   
   fclose(fid);

end
