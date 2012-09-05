function frames=muppet_readframes(pth)

txt=ReadTextFile([pth 'settings' filesep 'frames' filesep 'frames.def']);
 
k=1;

noframes=str2num(txt{k});
k=k+1;
 
for i=1:noframes
    frames(i).name=txt{k};
    k=k+1;
    frames(i).number=str2num(txt{k});
    k=k+1;
    for j=1:frames(i).number
        k=k+1;
        frames(i).frame(j).position(1)=str2num(txt{k});
        k=k+1;
        frames(i).frame(j).position(2)=str2num(txt{k});
        k=k+1;
        frames(i).frame(j).position(3)=str2num(txt{k});
        k=k+1;
        frames(i).frame(j).position(4)=str2num(txt{k});
        k=k+1;
    end
    frames(i).textnumber=str2num(txt{k});
    k=k+1;
    for j=1:frames(i).textnumber
        k=k+1;
        frames(i).text(j).position(1)=str2num(txt{k});
        k=k+1;
        frames(i).text(j).position(2)=str2num(txt{k});
        k=k+1;
        frames(i).text(j).horizontalalignment=txt{k};
        k=k+1;
    end
    frames(i).numberlogos=str2num(txt{k});
    k=k+1;
    for j=1:frames(i).numberlogos
        k=k+1;
        fname=txt{k};
        if isempty(fileparts(fname))
            frames(i).logo(j).file=[pth 'settings' filesep 'logos' filesep txt{k}];
        else
            frames(i).logo(j).file=fname;
        end
        k=k+1;
        frames(i).logo(j).position(1)=str2num(txt{k});
        k=k+1;
        frames(i).logo(j).position(2)=str2num(txt{k});
        k=k+1;
        frames(i).logo(j).position(3)=str2num(txt{k});
        k=k+1;
    end
end
