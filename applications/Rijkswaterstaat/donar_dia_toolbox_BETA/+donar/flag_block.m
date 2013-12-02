function  dat = flag_block(dat,thefield)
%FLAG_BLOCK  flag donar values for unrealistic values
%
%  block_data = donar.flag_block(thefield,block_data)
%
% where field is PAR{2} from donar.read_hdr() or
% Info(:).hdr.PAR{2} from donar.scan_file() and
% block_data = donar.read_block().

% block_data get's en extra column with these flags.
%
%  Code 1: Everything OK
% Flag strange values. 
%  Code 20: Unfeasible value
%  Code 300: Negative depth
%
%See also: 

%% Flag values out of the model domain: Code 1
    
    ncolumn = size(dat,2) + 1
    dat(:,ncolumn+1) = 1; % add extra column, default with 1 = OK

%% Flag "unfeasible" variable values: Code 20
    j = ncolumn-1 % variable columns
    switch lower(thefield)
        case{'zuurstof'}      % 0 < zuurstof
            ind = dat(:,j) < 0;                      dat(ind,ncolumn+1) = 20;
        case{'fluorescentie'} % 0 < fluorescentie < 100
            ind = (dat(:,j) > 100 | dat(:,j) < 0);   dat(ind,ncolumn+1) = 20;
        case{'zuurgraad'}     % 7 < pH < 9 
            ind = (dat(:,j) > 14  | dat(:,j) < 0);   dat(ind,ncolumn+1) = 20;
        case{'saliniteit'}    % 0 < saliniteit < 36
            ind = (dat(:,j) > 36  | dat(:,j) < 0);   dat(ind,ncolumn+1) = 20;
        case{'temperatuur'}   % -40 < temperatuur < 40
            ind = (dat(:,j) > 40  | dat(:,j) < -40); dat(ind,ncolumn+1) = 20;
        case{'troebelheid'}   % 0 < troebelheid < 500
            ind = (dat(:,j) > 500 | dat(:,j) < 0);   dat(ind,ncolumn+1) = 20;
        case{'geleidendheid'}

    end
    
%% Flag values with negative depths: Code 3

    ind = dat(:,3) < 0; dat(ind,ncolumn+1) = dat(ind,ncolumn+1) + 300; % 

end