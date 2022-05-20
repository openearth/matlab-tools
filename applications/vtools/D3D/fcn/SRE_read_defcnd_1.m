%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function defcnd_1=SRE_read_defcnd_1(path_defcnd_1)

%%

fid=fopen(path_defcnd_1,'r');
defcnd_1=struct();
while ~feof(fid)
    flin=fgetl(fid);
%     flin='STBO id ''7151923'' nm ''(null)'' ci ''P_P_003'' stbo';
%     flin='FLBR id ''22'' nm ''getymas1'' ci ''017'' lc 4598 flbr';
    tok=regexp(flin,'(\w*) id ''(\w+)'' nm ''\(?(\w+(?:\s?\w+))\)?'' ci ''(\w+)''','tokens');
    if isempty(tok)
        error('I could not get the string')
    else
        if isfield(defcnd_1,tok{1,1}{1,1})==0
            kl=1;
        else
            ne=numel(defcnd_1.(tok{1,1}{1,1}));
            kl=ne+1;
        end
        defcnd_1.(tok{1,1}{1,1})(kl).id=tok{1,1}{1,2};
        defcnd_1.(tok{1,1}{1,1})(kl).nm=tok{1,1}{1,3};
        defcnd_1.(tok{1,1}{1,1})(kl).ci=tok{1,1}{1,4};
    end
    
end

end %function