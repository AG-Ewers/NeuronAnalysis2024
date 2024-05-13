function [inputSkl] = fixCircles(inputSkl, D2, max_val)
%fixCircles removes circulararities induced by branch points
%   searches for points where branches diverge and cut one of them
    disp('    ....fixing circular structures in skeleton');
    
    numPaths = inf;
    count = 0;
    
    while numPaths > 1 || count > sum(~isnan(D2(:)))-1
        count = count + 1;
        fixbranch = find(D2 == max_val-count);
        numPaths = nnz(fixbranch);

    end
    
    fixbranch = find(D2 == max_val-(count-1));
    inputSkl(fixbranch(1)) = 0;
    
end

