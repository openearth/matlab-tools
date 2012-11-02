function [u,v,d,dp] = getpatterns(options,vdepth)
    %GETPATTERNS Captures the patterns of the original Matrix.
    %[P,V,D,Dprcnt] = getpatterns(A) returns the matrix P (corresponding to 
    %the matrix U of patterns) of the singular value decomposition. V is the
    %matrix of eigenvectors of the matrix A'A and D is a diagonal matrix of
    %corresponding eigenvalues. Dprcnt is a vector with the percentage that
    %each eigenvalue represent from the total sum of eigenvalues. 
    %
    %  P - Selected Patterns (Explain: XX% of the variance)
    %  V - EigenVectors
    %  D - EigenValues
    %  Dprcnt - Importance of eigenvalue as percentage
    
    %vdepth = 
    
    
    if options.normalize
        vdepth = vdepth./repmat( (sum(vdepth.^2)).^0.5,size(vdepth,1),1);
    end
    
    G = vdepth'*vdepth;                                                    % Following the pattern recognition technique
    [v,d] = eig(G);                                                        % idem

    v = fliplr(v);         % Get the eigenvectors in order
    d = flipud(diag(d));   % Get the eigenvalues in order
    dp = single(cumsum(d./sum(d)).*100);                                     % Get singular values as percentage of the whole
    
    if strcmpi(options.type,'energy'),     
        u = vdepth*(v(:,dp <= options.criterion)*sqrt(diag(1./d(dp<=options.criterion))));         % idem
    elseif strcmpi(options.type,'number'), 
        u = vdepth*(v(:,1:options.criterion)*sqrt(diag(1./d(1:options.criterion))));         % idem
    end