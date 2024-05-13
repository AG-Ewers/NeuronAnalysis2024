function [Branches, newSkl, newEndPoints] = findNextOrderBranch(inputSkl, higherOrderPath, prevEndPoints, MIN_LEN)
%findNextOrderBranch returns longest paths originating from inputPath
    
    % reduce higherOrderPaths to one mask 
    pathSum = false(size(inputSkl));
    for k = 1:size(higherOrderPath)
        pathSum = higherOrderPath{k} | pathSum;
    end


%% find starting points on path
newSkl = inputSkl & ~pathSum;

% find new endpoints (as the difference of current and previous endpoints
MoreEndPoints=find(bwmorph(newSkl,'endpoints'));
NewStartPoints = setdiff(MoreEndPoints, prevEndPoints); 


% disappearing branch points?
prevBranchPoints = find(bwmorph(inputSkl,'branchpoints'));
lessBranchPoints = find(bwmorph(newSkl,'branchpoints'));
lostBranchPoints = setdiff(prevBranchPoints, lessBranchPoints);
NewStartPoints = [NewStartPoints; lostBranchPoints];

% find relevant points
dilatedMask = imdilate(pathSum, ones(5));
NewStartPoints = NewStartPoints(dilatedMask(NewStartPoints));


Branches = cell(size(NewStartPoints));
newEndPoints = zeros(size(NewStartPoints));



%% find longest paths from these points
disp('    ...finding');
  for k = flip(1:nnz(NewStartPoints)) % going backwards (in case one is removed)
        [Branches{k}, newEndPoints(k), newSkl] = findLongestConnected(NewStartPoints(k), newSkl);
        
        if nnz(Branches{k}) == 0
                len = 0;
            else
                len = regionprops(Branches{k},  'PerimeterOld').PerimeterOld/2;
        end
            
        % if length of Branches{k} < MIN_LEN) -> remove path (& start point)
        if  len < MIN_LEN
            newSkl = newSkl & ~Branches{k};
            Branches{k} = [];
            prevEndPoints = setdiff(prevEndPoints, newEndPoints(k));
            newEndPoints(k) = [];          
        end
  end
  
%% check for overlap
disp('    ...refining');
  [newSkl, Branches, newEndPoints ] = fixOverlap(newSkl, NewStartPoints, Branches, newEndPoints, MIN_LEN );



%% remove deleted branches from output
Branches = Branches(~cellfun('isempty',Branches));
    newEndPoints = setdiff(prevEndPoints, newEndPoints);

end

