function FindTransformationOptions

load EPSG.mat

ngeo2=0;
ngeo3=0;
nproj=0;
nother=0;
%n=length(EPSG.coordinate_reference_system);

CoordinateSystems=EPSG.coordinate_reference_system;
Operations=EPSG.coordinate_operation;

n=0;
for i=1:length(CoordinateSystems)
    h=CoordinateSystems(i).coord_ref_sys_kind;
    switch(h),
        case {'geographic 2D'}
            n=n+1;
            cs(n)=CoordinateSystems(i);
            codes(n)=cs(n).coord_ref_sys_code;
    end
end

DefaultDatumTransformation.crscodes=codes;

DefaultDatumTransformation.transcodes=nan(n,n,2);
DefaultDatumTransformation.ireverse=nan(n,n,2);
DefaultDatumTransformation.interm=nan(n,n);
n
kstart=43;
kstop=n-294;
for i=kstart:kstop
    i
    cs1code=codes(i);
    for j=kstart:kstop
        cs2code=codes(j);

        ok=0;

        % Try first option
        [icode]=findoptions(cs1code,cs2code,Operations);
        if ~isempty(icode)
            disp(['Found codes for ' num2str(i) ' and ' num2str(j) ' - first']);
            DefaultDatumTransformation.transcodes(i,j,1)=icode;
            DefaultDatumTransformation.ireverse(i,j,1)=1;
            ok=1;
        end
        
        if ~ok
            % Try second option
            [icode]=findoptions(cs2code,cs1code,Operations);
            if ~isempty(icode)
                disp(['Found codes for ' num2str(i) ' and ' num2str(j) ' - second']);
                DefaultDatumTransformation.transcodes(i,j,1)=icode;
                DefaultDatumTransformation.ireverse(i,j,1)=-1;
                ok=1;
            end
        end
        
        if ~ok

            ok2=0;
            % Try intermediate option (first convert to WGS84)
            [icode]=findoptions(cs1code,4326,Operations);
            if ~isempty(icode)
                code1=icode;
                ok2=1;
            end
            
            % Then from WGS84 to code2
            if ok2
                ok2=0;
                [icode]=findoptions(cs2code,4326,Operations);
                if ~isempty(icode)
                    code2=icode;
                    ok2=1;
                end
            end

            if ok2
                disp(['Found codes for ' num2str(i) ' and ' num2str(j) ' - intermediate']);
                DefaultDatumTransformation.transcodes(i,j,1)=code1;
                DefaultDatumTransformation.transcodes(i,j,2)=code2;
                DefaultDatumTransformation.ireverse(i,j,1)=1;
                DefaultDatumTransformation.ireverse(i,j,2)=-1;
                DefaultDatumTransformation.interm(i,j)=4326;
            end
            
        end

    end
end

function icode=findoptions(cs1code,cs2code,Operations)
icode=[];
poscodes=findinstruct(Operations,'source_crs_code',cs1code,'target_crs_code',cs2code);
if ~isempty(poscodes)
    var0=0;
    icode=[];
    for k=1:length(poscodes)
        poscode=poscodes(k);
        switch Operations(poscode).coord_op_method_code,
            case{9603,9606,9607}
                if Operations(poscode).coord_op_variant>var0
                    var0=Operations(poscode).coord_op_variant;
                    icode=poscode;
                end
        end
    end
end
