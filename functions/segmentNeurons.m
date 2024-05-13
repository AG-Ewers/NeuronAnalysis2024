function Seg_Image = segmentNeurons(I , thickness_pixel, gap_size_pixel, gap_bridge_check)
% segmentNeurons will take an 8bit grayscale image of a 2D neuron and segment the neuron. 

% reducing 3 channel image to grayscale as a safety measure
if length(size(I)) == 3
    I = rgb2gray(I);
end

%% Fiber Metric enhancement of tubular structures (based on their thickness)

B = fibermetric(I,'StructureSensitivity',thickness_pixel);

%% Initial Segmentation

BW = B > 0.05;
[row,col,~]=size(BW);


%% remove perfectly vertical or horizontal lines (stitching artifacts)
% find horizontal
Cleaned = BW;
toKeep = false(size(BW));
for k = 1:row
    CountConsequtive = 1;
    for j = 2:col
        if Cleaned(k,j) == 1 && Cleaned(k,j-1) == 0
            CountConsequtive = 1;
        elseif Cleaned(k,j) == 1 && Cleaned(k,j-1) == 1
            toKeep(k, j) = 1; 
            CountConsequtive = CountConsequtive + 1;
        elseif Cleaned(k,j) == 0 && Cleaned(k,j-1) == 1
            if CountConsequtive < 300
                for l = 0:CountConsequtive-1
                    toKeep(k,j-l) = 0;
                end
            end
            CountConsequtive = 0;
        else
            CountConsequtive = 0;
            
        end
    end
end

Cleaned = Cleaned & ~toKeep;

toKeep = false(size(BW));

% Detect vertical
for k = 1:col
    CountConsequtive = 0;
    for j = 2:row
        if Cleaned(j,k) == 1 && Cleaned(j-1,k) == 0
            CountConsequtive = 1;
        elseif Cleaned(j,k) == 1 && Cleaned(j-1,k) == 1
            toKeep(j,k) = 1; 
            CountConsequtive = CountConsequtive + 1;
        elseif Cleaned(j,k) == 0 && Cleaned(j-1,k) == 1
            if CountConsequtive < 300
                for l = 0:CountConsequtive-1
                    toKeep(j-l,k) = 0;
                end
            end
            CountConsequtive = 0;
        else
            CountConsequtive = 0;
        end
    end
end

Cleaned = Cleaned & ~toKeep;

BW = Cleaned;
BW_thin0 = bwmorph(BW , 'open', 1); % remove the remaining thin stitching artifacts



%% Bridge by finding endpoints of skeleton and connecting those below threshold


BW_thicken = bwmorph(BW_thin0 , 'thicken', round(thickness_pixel/2)); % reduce the number of points to look at
BW_thicken = bwmorph(BW_thicken , 'bridge', round(thickness_pixel/2)); % 0.5 µm

% If gap-briding is enabled
if (gap_bridge_check)
    % Bridge by connecting endpoints
    disp('      Bridging gaps');
    %disp(gap_size_pixel);
    BW_bridges = bridgeGaps(BW_thicken, gap_size_pixel);
else
    BW_bridges = BW_thicken;    
end

BW_bridges = bwmorph( BW_bridges, 'dilate', round(thickness_pixel/2)); % make connections thicker
BW_bridged = BW_thicken | BW_bridges;

BW_thin = ~bwmorph(~BW_bridged, 'open', 1); % fill tiny holes introduced by bwmorph-bridge
BW_thin = bwmorph(BW_thin , 'thin', 2);


%% Adaptive size threshold 
Sizes = regionprops(BW_thin, 'area'); Sizes = struct2table(Sizes);
Sorted_Sizes = sortrows(Sizes); Sorted_Sizes = table2array(Sorted_Sizes);

P = round(Sorted_Sizes(end,:)/10);

% limiting size threshold
if (P > 500)
    P = 500;
end

% Size-Thresholding (removing smaller objects)
BW_RemovedSmallObjs = bwareaopen(BW_thin, P);  % Remove objects smaller than P pixel in size


%% Image Filling for Soma detection

BW_filledHoles = imfill(BW_RemovedSmallObjs, 'holes');

% find brightest parts in image & remove attached neurites
SomaInt = I > 0.4 * max(max(I));
SomaInt = bwmorph(SomaInt, 'erode', thickness_pixel);
SomaInt = bwmorph(SomaInt, 'dilate', thickness_pixel);

% find largest overlap of filled parts and high intensity areas > potential soma-seeds
Relevant_filling = SomaInt & BW_filledHoles;
Relevant_filling = bwareafilt(Relevant_filling,2); % keep only largest 2

% To avoid over-filling in cases where dendrites branch much close around soma
% fill only parts in vicinity (here: 3 µm, could be a variable) of "intensity" soma
Fill_area = bwmorph(Relevant_filling , 'dilate', 3 * thickness_pixel);
To_fill = Fill_area & BW_RemovedSmallObjs;

Soma = imfill(To_fill, 'holes');
% -> this way overfilling is never larger than the "intensity" soma

% merge Soma region with refined skeleton
Final_Seg = BW_RemovedSmallObjs | Soma;

% Test if filling did increase the skeleton area at all
% original skeleton area
Sizes = regionprops(BW_RemovedSmallObjs, 'area'); Sizes = struct2table(Sizes); 
Sorted_Sizes_beforeFill = sortrows(Sizes); Sorted_Sizes_beforeFill = table2array(Sorted_Sizes_beforeFill);

% after filling skeleton area
Sizes = regionprops(Final_Seg, 'area'); Sizes = struct2table(Sizes); 
Sorted_Sizes_afterFill = sortrows(Sizes); Sorted_Sizes_afterFill = table2array(Sorted_Sizes_afterFill);


% If no Filling occured > resort to Thresholding
if Sorted_Sizes_afterFill(end,:) < 1.001 * Sorted_Sizes_beforeFill(end,:) % if the size change was not noticable
    disp('      Image Filling not successful! Soma will be found by thresholding!');
    
    % find brightest parts of image and remove thin extensions
    SomaInt = I > 0.3 * max(max(I));
    SomaInt = bwmorph(SomaInt, 'erode', thickness_pixel+1);
    SomaInt = bwmorph(SomaInt, 'dilate', thickness_pixel+1);
    
    % Find the one with largest overlap to refined skeleton
    Overlap = BW_RemovedSmallObjs & SomaInt;
    SomaSeed = bwareafilt(Overlap,1);
    
    % Keep only filled parts in vicinity of Soma
    Fill_area = bwmorph(SomaSeed , 'dilate', 10 * thickness_pixel);
    Fill_area = imfill(Fill_area, 'holes');
    SomaInt = imfill(SomaInt, 'holes');
    Soma = Fill_area & SomaInt;

    Final_Seg = BW_RemovedSmallObjs | Soma;

else
    disp('      Soma found by filling.');
end



%% Final Segmentation Result

% in case there is more than one object, just keep the largest one
Seg_Image =  bwareafilt(Final_Seg,1);    
