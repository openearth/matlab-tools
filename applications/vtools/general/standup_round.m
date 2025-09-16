function standup_round()

rng(datenum(datetime('now'))*5000) %changes every 10 or 15 s more or less
Names = {'Johan Reyns','Victor Chavarrias','Willem Ottevanger','Bert Jagers','Marcio Boechat','Qilong Bi','Joao Dobrochinski','Zeta Tam','Adri Mourits'};
[~,isort] = sort(rand(1,numel(Names)));
Names(isort)'

end