function standup_round()

Names = {'Johan Reyns','Victor Chavarrias','Willem Ottevanger','Bert Jagers','Marcio Boechat','Qilong Bi','Joao Dobrochinski','Zeta Tam','Adri Mourits'};
[~,isort] = sort(rand(1,numel(Names)));
Names(isort)'

end