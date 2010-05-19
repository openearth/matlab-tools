function [struc,iac,nr]=UpDownDeleteStruc(struc,iac,opt)

nr=length(struc);

switch lower(opt)
    case{'up','moveup'}
        if nr>1 && iac>1
            a=struc(iac-1);
            struc(iac-1)=struc(iac);
            struc(iac)=a;
            iac=iac-1;
        end
    case{'down','movedown'}
        if nr>1 && iac<nr
            a=struc(iac+1);
            struc(iac+1)=struc(iac);
            struc(iac)=a;
            iac=iac+1;
        end
    case{'delete'}
        if nr>0
            if nr>iac
                for k=iac:nr-1
                    struc(k)=struc(k+1);
                end
            else
                iac=iac-1;
            end
            struc=struc(1:nr-1);
        end
end

nr=length(struc);
