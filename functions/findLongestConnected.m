function [tempP, endPoint, inputSkl] = findLongestConnected(start, inputSkl)
%findLongestConnected will find the longest path in a branch given a starting point
    
    % only start if the starting point is still in the skeleton
    if ~ismember( start, find(inputSkl))
        tempP = false(size(inputSkl));
        endPoint = 0;
    else
        
   
    % determine geodesic from a given start point
    D2 = bwdistgeodesic(inputSkl, start);
    D2(D2==inf) = NaN; % ignore unconnected parts
    
      
    % find index of maximal distance of start point
    [max_val , endPoint] = max(D2(:));


    % detect if the max-distance is not reached at an endpoint (= circular paths in the skeleton)
    % find endpoints of the current skeleton 
    endPoints=find(bwmorph(inputSkl,'endpoints'));

    % if none of the endPoints is found on the connected parts, skip it
    if sum(ismember(endPoints, find(~isnan(D2))))==0
        tempP = false(size(inputSkl));
        endPoint = 0;
    else
        while ~ismember(endPoint, endPoints) % as long as cirularity is still detected in the skeleton
            % cut one of the branch points to remove circularity
            inputSkl = fixCircles(inputSkl, D2, max_val);

            % determine geodesic from a given start point
            D2 = bwdistgeodesic(inputSkl, start);
            D2(D2==inf) = NaN; % ignore unconnected parts

            % find index of maximal distance of start point
            [max_val , endPoint] = max(D2(:));
            endPoints=find(bwmorph(inputSkl,'endpoints'));
        end

        % after fixing circles find the direct path between those points
        D1 = bwdistgeodesic(inputSkl, endPoint);
        D = D1 + D2;
        D = round(D * 8) / 8;
        D(isnan(D)) = inf;
        tempP = imregionalmin(D);
    end
        
    end
end

