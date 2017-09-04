      function [conc] = nesthd_hisncc(filename,istat,nfs_inf,l)

      % nesthd_hisncc : gets concentrations from DFLOWFM history file

      %% Initialisation
      kmax   = nfs_inf.kmax;
      notims = nfs_inf.notims;
      
      %% Variables on his file
      Info = ncinfo(filename);
      Vars = {Info.Variables.Name};
      i_conc = find(strcmpi(Vars,strtrim(nfs_inf.namcon(l,1:20)))==1);

%%    Get Concentration data
      data_all  = ncread(filename,Vars{i_conc});
      if  nfs_inf.kmax == 1         % depth averaged
          conc = data_all(istat,:);
      else
          conc = squeeze(data_all(:,istat,:))';
      end
