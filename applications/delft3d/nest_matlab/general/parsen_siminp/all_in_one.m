function S = all_in_one(S)

hulp = [];

for irec = 1: length(S.File)
   if isempty(strfind(lower(S.File{irec}),'include'))
      hulp{end+1} = S.File{irec};
   else
       
      %
      % get the filename and read the contents, add to hulp
      %

      contents = sscanf(S.File{irec},'%s');
      istart   = strfind(lower(contents),'include');
      if istart > 1
          hulp{end+1} = contents(1:istart - 1);
      end
      istart   = strfind(lower(contents),'file') + 5;
      filename = contents(istart:end-1);
      hulp2    = readsiminp(S.FileDir,filename);
      hulp(end+1:end + length(hulp2.File)) = hulp2.File;
   end
end

S.File = hulp;
