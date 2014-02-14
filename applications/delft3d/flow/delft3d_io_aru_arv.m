function varargout = delft3d_io_aru_arv(varargin)
%DELFT3D_IO_ARU_ARV   read and write Delft_3D .aru and .arv files
%
% %example:
% S.data{1}.comment = '# Example aru/arv file';
% S.data{2}.n = 12;
% S.data{2}.m = 20;
% S.data{2}.definition = 8;
% S.data{2}.percentage = 0.4;
% S.data{3}.n1 = 10;
% S.data{3}.m1 = 20;
% S.data{3}.n2 = 40;
% S.data{3}.m2 = 23;
% S.data{3}.definition = 13;
% S.data{3}.percentage = 0.4;
% S.data{4}.comment = '*another comment';
%
% %save example file 
% delft3d_io_aru_arv('write','example.aru',S);
%
% %read example file 
% T = delft3d_io_aru_arv('read','example.aru');
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd,
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva,
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf,
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src,
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd,

% delft3d_io_aru_arv_version = '1.0beta';
if nargin ==1
    error(['At least 2 input arguments required: d3d_io_...(''read''/''write'',filename)'])
end

if nargin ==2
    cmd   = varargin{1};
    fname1 = varargin{2};
end

if nargin == 3
    cmd    = varargin{1};
    fname1 = varargin{2};
    T      = varargin{3};
end


%% Read
if strcmp(cmd,'read')
    tmp               = dir(fname1);
    if length(tmp)==0
        error(['aru/arv file ''',fname1,''' does not exist.'])
    end
    
    S=Local_read(fname1);
    varargout{1}  = S;
    %% Write
elseif strcmp(cmd,'write')
    tmp               = dir(fname1);
    if length(tmp)>0
        error(['aru/arv file ''',fname1,''' already exists.'])
    end
    S=Local_write(fname1,T);
    varargout{1}  = S.iostat;
else
    help('delft3d_io_aru_arv')
end
end


function S = Local_write(varargin)
filename = varargin{1};
T        = varargin{2};
fid = fopen(filename,'w');
S.iostat = -1;
for k = 1:length(T.data);
    counts = [ ...
        length(setdiff(lower(fieldnames(T.data{k})),{'comment'})), ...
        length(setdiff(lower(fieldnames(T.data{k})),{'nm','definition','percentage'})), ...
        length(setdiff(lower(fieldnames(T.data{k})),{'n','m','definition','percentage'})), ...
        length(setdiff(lower(fieldnames(T.data{k})),{'n1','m1','n2','m2','definition','percentage'})), ...
        ];
    [y, type_no] = min(counts);
    switch (type_no)
        case 1
            fprintf(fid,'%s\n',T.data{k}.comment);
        case 2
            fprintf(fid,'%5i %5i  %f\n',T.data{k}.nm, T.data{k}.definition, T.data{k}.percentage);
        case 3
            fprintf(fid,'%5i %5i %5i  %f\n',T.data{k}.n, T.data{k}.m, T.data{k}.definition, T.data{k}.percentage);
        case 4
            fprintf(fid,'%5i %5i %5i %5i %5i  %f\n',T.data{k}.n1, T.data{k}.m1, T.data{k}.n2, T.data{k}.m2, T.data{k}.definition, T.data{k}.percentage);
    end
    if y ~= 0
        fclose(fid)
        error('incorrect structure passed to delft_io_aru_arv');
    end
end
S.iostat = 1;
fclose(fid);
end

function S = Local_read(varargin)

S.filename = varargin{1};

fid          = fopen(S.filename,'r');
if fid==-1
    S.iostat   = fid;
else
    S.iostat   = -1;
    line_no = 0;
    while 1
        %% get line
        newline          = fgetl(fid);
        if ~ischar(newline);break, end % -1 when eof
        line_no = line_no + 1;
        if (length(newline) > 0)
            if (sum(strfind('#*',newline(1)))>0);
                type    = 'comment';
                content = newline;
            else
                content = str2num(newline);
                if length(content) == 4;
                    type    = 'n m definition percentage';
                elseif length(content) == 6;
                    type    = 'n1 m1 n2 m2 definition percentage';
                elseif length(content) == 3;
                    type    = 'nm definition percentage';
                else
                    type    = 'unknown';
                    content = newline;
                end
            end
        else
            type    = 'comment';
            content = newline;
        end
        count = 0;
        desc = regexp(type,' ','split');
        if length(desc) == 1;
            S.data{line_no}.(desc{1}) = content;
        else
            for str = regexp(type,' ','split')
                count = count+1;
                S.data{line_no}.(str{1}) = content(count);
            end
        end
    end
    fclose(fid);
    S.iostat   = 1;
end

if (S.iostat == -1)
    error(['Error reading aru/arv file ',S.filename]);
end
end
%
% if strcmp(cmd,'read')
%
% end
%
%
%
% %   G = delft3d_io_grd('read' ,filename)
% % read delft3d grid
% grid = wlgrid('read','d:\ottevan\Documents\source\cases_delft3d\trachytopes-fm_convert\testunif.grd');
%
% [mmax,nmax] = size(grid.X);
% grid.X = [grid.X,zeros(mmax,1)];
% grid.X = [grid.X;zeros(1,nmax+1)];
% grid.Y = [grid.Y,zeros(mmax,1)];
% grid.Y = [grid.Y;zeros(1,nmax+1)];
% mmax = mmax + 1;
% nmax = nmax + 1;
%
%
% n = floor(rand(1)*nmax)+1;
% m = floor(rand(1)*mmax)+1;
%
% % Delft3D walks through the matrix in another order than Matlab
% nm = n_and_m_to_nm(m,n,mmax,nmax);
% gridt.X = grid.X.';
% gridt.Y = grid.Y.';
% [grid.X(m,n) == gridt.X(nm)]*[grid.Y(m,n) == gridt.Y(nm)]
% [gridt.X(n,m) == gridt.X(nm)]*[gridt.Y(n,m) == gridt.Y(nm)]
%
% cmd = 'read'
%
% %function varargout=Local_read(bcafile,BND)
% %%
% %OPT.debug = 0;
% clc
% arufiles = {'d:\ottevan\Documents\source\cases_delft3d\trachytopes-fm_convert\tt2.aru','d:\ottevan\Documents\source\cases_delft3d\trachytopes-fm_convert\tt2.arv'};
% figure(1);
% hold on;
%
% ncfile = 'd:\ottevan\Documents\source\cases_delft3d\trachytopes-fm_convert\fmsim\tt3_net.nc';
% GF = dflowfm.readNet(ncfile);
%
% fid3  = fopen([arufile{1}(1:end-4),'_fm.aru'],'w');
%
% for arufile = arufiles
%     fid   = fopen(arufile{1},'r');
%     fid2  = fopen([arufile{1}(1:end-4),'_delft3d_link',arufile{1}(end-3:end)],'w');
%
%     fprintf(fid3, '%s\n', '* Converted from Delft3D input file' );
%     fprintf(fid3, '%s\n', ['* ',arufile{1}]);
%
%     if arufile{1}(end) == 'u';
%         udir = 1;
%     else
%         udir = 0;
%     end
%
%     colstr = jet(10);
%
%     while 1
%         tline = fgetl(fid);
%         if ~ischar(tline), break, end
%         nums = str2num(tline);
%         if length(nums)==0
%             fprintf(fid2, '%s\n', tline);
%             fprintf(fid3, '%s\n', tline);
%         elseif length(nums)==3
%             fprintf(fid2, '%s\n', tline);
%             fprintf(fid3, '%s\n', tline);
%         elseif length(nums)==4
%             n    = nums(1);
%             m    = nums(2);
%             def  = nums(3);
%             perc = nums(4);
%             if (m < mmax-(1-udir)) && (n < nmax-udir)
%                 [x1,y1,x2,y2] = get_link_from_grid(m,n,udir,grid);
%                 fprintf(fid2, '%i  %i  %2.2f\n', nm, def, perc);
%                 %find link number in net file of FM
%                 [L] = dflowfm.get_link_from_net(x1,y1,x2,y2,GF);
%                 fprintf(fid3, '%i  %i  %2.2f\n', L, def, perc);
%             end
%         elseif length(nums)==6
%             m1   = nums(2);
%             n1   = nums(1);
%             m2   = nums(4);
%             n2   = nums(3);
%             def  = nums(5);
%             perc = nums(6);
%             for m = [m1:m2]
%                 for n = [n1:n2]
%                     nm = n_and_m_to_nm(m,n,mmax,nmax);
%                     if (m < mmax-(1-udir)) && (n < nmax-udir)
%                         %find link number in net file of Delft3D
%                         [x1,y1,x2,y2] = get_link_from_grid(m,n,udir,grid);
%                         fprintf(fid2, '%i  %i  %2.2f\n', nm, def, perc);
%                         %find link number in net file of FM
%                         [L] = dflowfm.get_link_from_net(x1,y1,x2,y2,GF);
%                         fprintf(fid3, '%i  %i  %2.2f\n', L, def, perc);
%                     end
%                 end
%             end
%         end
%     end
%     fclose(fid);
%     fclose(fid2);
% end
% fclose(fid3);
% %%
% G = delft3d_io_grd('read','d:\ottevan\Documents\source\cases_delft3d\trachytopes-fm_convert\testunif.grd');
%
% % make table with link numbers (m, n, nm) and x1, y1, x2, y2 locations
% % grid1.X(m,n), grid1.Y(m,n)
%
% % xz_(nm) =approx xu(nm) + xu(nmd) + xv(nm) + xv(ndm)
% % hold on;
% % plot(T.cor.x(9:10,10),T.cor.y(9:10,10),'b.-')
% % plot(T.cor.x(10,9:10),T.cor.y(10,9:10),'g.-')
% % plot(T.cen.x(10,10)  ,T.cen.x(10,10)  ,'r.')
% % title('Visualization of nm in u/v/z points')
%
% % link_x =
%
%
% %plot(T.cor.x(10,9:10),T.cor.y(10,9:10),'b.-')
%
%
% % call n_and_m_to_nm
% % read aru/arv files
% % convert aru/arv input to list of link numbers and definitions and percentages in u/v direction
%
%
% % read net file
% % make table of net_link numbers
% % make translationtable from link numbers to net_link numbers
%
% % combine link number tables (sorting? x,y)
