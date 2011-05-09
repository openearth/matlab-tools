function qcd(directory),
%QCD Change current working directory using partial name.
%    QCD <begin of dir. name>
%
%    Example: QCD ma
%             will change the current working directory
%             to the matlab subdirectory if there is no
%             other directory that starts with ma.

% (c) copyright, H.R.A. Jagers, May 13 2001

if ~strcmp(filesep,'/') & ~isempty(findstr(directory,'/'))
   directory=strrep(directory,'/',filesep);
end

if exist(directory)==7
   cd(directory)
else
   dirparts=multiline(directory,filesep,'cell');
   for i=1:length(dirparts)
      tdir=cat(2,dirparts{1:i},filesep);
      if exist(tdir)~=7
         sdir=[tdir(1:end-1) '*'];
         D=dir(sdir);
         isdirec=cat(1,D.isdir);
         D=D(isdirec);
         [j,altdir]=ustrcmpi(dirparts{i},{D.name});
         if isempty(altdir) % j==-1
            error(['No matching directory found: ' sdir]);
         elseif j<0 % j==-1
            pdir=cat(2,dirparts{1:i-1});
            for s=1:length(altdir)
               altdir{s}=[pdir altdir{s}];
            end
            Msg=cat(2,sprintf('Multiple matching directories:\n'),sprintf('%s\n',altdir{:}));
            error(Msg);
         else
            dirparts{i}=altdir;
         end
      end
      dirparts{i}=[dirparts{i} filesep];
   end
   cd(cat(2,dirparts{1:i}));
end
fprintf('Current working directory changed to: %s\n',pwd);