function [newSkel, Branches, endPoint ] = fixOverlap(newSkel, StartPoints, Branches, endPoint, MIN_LEN )
%fixOverlap tests for overlapping branches, keeps longest one and redetects new path for other starting point

    % find overlapping parts (even if more than two branches overlap)
    FlatBranch = Branches(~cellfun('isempty',Branches));
    NeuriteMat = zeros(size(newSkel));
    for m = 1:size(FlatBranch)
        NeuriteMat = NeuriteMat + FlatBranch{m};
    end

    %find largest overlap
    overlapMax = max(NeuriteMat(:));
    
    tempBranches = cell(size(Branches));        
        
    
    while overlapMax > 1
        % find longest path and remove it from skeleton
        [~, index] = max(cellfun(@nnz, Branches));  
        tempBranches{index} = Branches{index};
        newSkel = newSkel &~ Branches{index};
     
        for k = flip(1:nnz(StartPoints)) % going backwards (in case one is removed)

            [Branches{k}, endPoint(k), newSkel] = findLongestConnected(StartPoints(k), newSkel);

            % new length measurement: 
            % Perimeter of a line / 2 = length also for curved lines
            % does not work for empty objects though -> test with nnz()
            if nnz(Branches{k}) == 0
                len = 0;
            else
                len = regionprops(Branches{k},  'PerimeterOld').PerimeterOld/2;
            end
            

            % if length of Neurites{k} < MIN_LEN) -> remove path (& endpoint)
            if  len < MIN_LEN
                newSkel = newSkel & ~Branches{k};
                Branches{k} = []; 
                endPoint(k) = [];
            end
        end
        
        % reassess overlap
        FlatBranch = Branches(~cellfun('isempty',Branches));
        NeuriteMat = zeros(size(newSkel));
        for m = 1:size(FlatBranch)
            NeuriteMat = NeuriteMat + FlatBranch{m};
        end
        
        %find largest overlap
        overlapMax = max(NeuriteMat(:));
        
    end
        
    % combine refined Branches
      tempBranches = tempBranches(~cellfun('isempty',tempBranches)); 
      Branches = [tempBranches; FlatBranch];

      
      
 %% previous overlap detection 
 % sensitive to cases with >2 paths overlapping but much faster
 
%     for k = flip(1:(nnz(StartPoints)))
%     
%         if isempty(Branches{k})
%             continue
%         else
%             % display(k);
%             for j = flip(1:(nnz(StartPoints)-1))
%                 if isempty(Branches{j}) || isempty(Branches{k})
%                     continue
%                 elseif j == k % skip comparison to same neurite
%                     continue
% %                 elseif Branches{j} == Branches{k} % if two neurites are identical
% %                     Branches{k} = []; % delete currently checked Neurite
%                 else
%                     
%                 % find number of intersecting pixels
%                 n = numel(intersect(find(Branches{k}), find(Branches{j})));
%                 % display(j)
%                 if n > 0
%                     % find longer of the two
%                     if nnz(Branches{k}) > nnz(Branches{j})
%                        % start shorter with NeuriteStartPoints on that index
%                        newSkel = newSkel &~(Branches{k} & largestOverlap);
%                        % newSkel = newSkel & ~Branches{k};
%                         Branches{j} = [];
%                         [Branches{j}, endPoint(j), newSkel] = findLongestConnected(StartPoints(j), newSkel);
%                         len = nnz(Branches{j});
%                             % if length of Neurites{k} < MIN_LEN) -> remove path (& start point)
%                         if  len < MIN_LEN
%                             newSkel = newSkel & ~Branches{j};
%                             Branches{j} = [];
%                             endPoint(j) = [];
% 
%                        end
%                        
%                     else
%                         newSkel = newSkel & ~(Branches{j} & largestOverlap);
%                         % newSkel = newSkel & ~Branches{j};
%                         Branches{k} = [];
%                         [Branches{k}, endPoint(k), newSkel] = findLongestConnected(StartPoints(k), newSkel);                             
%                         len = nnz(Branches{k});
%                         if  len < MIN_LEN
%                             newSkel = newSkel & ~Branches{k};
%                             Branches{k} = [];
%                             endPoint(k) = [];
%                         end
%                     end
%                 end
%                 end
%             end
%         end
%     end
end

 