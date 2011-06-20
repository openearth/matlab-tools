function fi=tindex(t,ti);
%TINDEX find (floating point) index of time in array
%
%     FI = TINDEX(T,TI)
%     finds index of time T in time array TI. If T does
%     not occur exactly in TI, FI will be a floating point
%     index based on linearly interpolating two times of TI.

fi=max(find(t<=ti));
if isempty(fi),
  fi=1;
elseif fi~=length(t),
  fi=fi+(ti-t(fi))/(t(fi+1)-t(fi));
end;
