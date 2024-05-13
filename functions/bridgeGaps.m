function [cumulativeLines] = bridgeGaps(inputMask, gap_size_pixel)
%bridge_gaps takes a skeleton and connects endpoints closer than a minimal gap size


BW_skel = bwmorph(inputMask, 'skel', Inf);

BW_skel2 = bwareaopen(BW_skel, 12);  % Remove objects smaller than 12 pixel (3µm) in size


% find endpoints
points = bwmorph(BW_skel2, 'endpoints');

endPointsInd = find(points);
[endPointRows, ~] = ind2sub(size(BW_skel), endPointsInd);

% which objects do they belong to
[labeledImage, ~] = bwlabel(BW_skel);

theLabels = zeros(size(endPointRows));
numberOfEndpoints = length(endPointRows);

for k = 1:numberOfEndpoints
    theLabels(k) = labeledImage(endPointsInd(k));
end


%% connect endpoints with direct lines
% create plot to connect lines on (doesn't really work otherwise..)
image = false(size(BW_skel));
cumulativeLines = image;
tempfig = figure;
group = axes;
imshow(image);

remainingEndPoints = endPointsInd;


 while length(remainingEndPoints) > 1   


    [thisRow, thisColumn] = ind2sub(size(BW_skel), remainingEndPoints(k));
    
    % Get the label number of this segment
    thisLabel = labeledImage(remainingEndPoints(k));   
    
    
    % check if they are on the same segment
    onSameSegment = (theLabels == thisLabel); % List of what segments are the same as this segment   
    otherSegmentPoints = remainingEndPoints;
    otherSegmentPoints(onSameSegment) = [];
    [otherRows, otherCols] = ind2sub(size(BW_skel), otherSegmentPoints);

    % find nearest neighbor
    [Idx, D] = knnsearch([otherRows otherCols],[thisRow thisColumn] );
    
    % if the distance is short enough, connect endpoints
    if D < gap_size_pixel
        % Draw line from this endpoint to the other endpoint.
        linemask = imline(group,[thisColumn, thisRow ; otherCols(Idx), otherRows(Idx)]).createMask();
        cumulativeLines = cumulativeLines | linemask;

        remainingEndPoints(k) = [];
        theLabels(k) = [];
    else
         remainingEndPoints(k) = [];
         theLabels(k) = [];
    end
      k = k-1;

end
close(tempfig);

end

