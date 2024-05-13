function [cBody, skel, center] = FindCellBody(I, tol, extentThr , s , S, thickness_pixel)
%FindCellBody detects the cell body in a segmented image of a neuron based on morphological characteristics

% skeletonize image
skel = bwmorph(I,'thin',inf);


% find centroid of soma
while true
    B = imerode(I~=0, ones(s));
    B = bwareafilt(B,1);    % in case there are more than one Soma, just keep the largest one!
    if nnz(B) < S
        s = s - 2;
    else
        rp = regionprops(B, 'Centroid');
        y = round(rp.Centroid(1,1));
        x = round(rp.Centroid(1,2));
        break
    end
end

if~exist('extentThr', 'var')
    extentThr = -1;
end


% fill cell body by expanding until stopping conditions are met
cBody = false(size(I));
cBodyOld = cBody;
cBody(x, y) = true;

while(sum(cBody(:)) ~= sum(cBodyOld(:)))
    cBodyOld = cBody;
    p = imdilate(cBody, strel('disk',thickness_pixel, 0)) - cBody;
    vp = find(p);
    vpVal = I(vp);
    meanSeg = mean(I(cBody));
    cBody(vp(vpVal > meanSeg - tol & vpVal < meanSeg + tol)) = true;
    cBody = bwareafilt(cBody,1);    % in case there are more than one Soma, just keep the largest one!
    rp = regionprops(cBody, 'Extent');
    if rp.Extent < extentThr
        break
    end
end

% erode soma for more robust detection of neurites in later stages
%cBody = imreconstruct(cBody,imerode(cBody, strel('disk', thickness_pixel, 0))); 
I = cBody & skel;

cBody = bwareafilt(cBody,1);    % Again, in case there are more than one Soma, just keep the largest one!
rp = regionprops(cBody, 'Centroid');

c = round(rp.Centroid);
[~, ind] = bwdist(I);
center = double(ind(c(2), c(1)));
