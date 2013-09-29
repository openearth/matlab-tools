function mdu = simona2mdu_proces(mdf,mdu, name_mdu)

% siminp2mdu_proces : Detremine whether salinity = active or not

if strcmpi(mdf.sub1(1),'s') mdu.physics.Salinity = 1; end
end
