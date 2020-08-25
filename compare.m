close all;
clear;
clc;

%% initial import as overview

% get images (original, and two with segmentation)
image_slice_full = dicomread(fullfile('data', 'slice.dcm'));
image_User1_full = dicomread(fullfile('data', 'slice_User1.dcm'));
image_User2_full = dicomread(fullfile('data', 'slice_User2.dcm'));

% set reference scale
grayscaleRange = [0, max(image_slice_full(:))]; % [] for auto-scale to min-max

% clip to region of interest
rows = 253:302; % 1:size(image_slice_full, 1);
cols = 218:267; % 1:size(image_slice_full, 2);
image_slice_clip = image_slice_full(rows, cols);
image_User1_clip = image_User1_full(rows, cols);
image_User2_clip = image_User2_full(rows, cols);

% show the slice
figure('Name', 'Slice overview', 'Color', 'w');
subplot(1, 2, 1); % left, show all
imshow(image_slice_full, grayscaleRange);
hold('on');
rectPos = [cols(1), rows(1), cols(end)-cols(1), rows(end)-rows(1)];
rectangle('Position', rectPos, 'EdgeColor', 'r');
title('Slice');
subplot(1, 2, 2); % right, show subset
imshow(image_slice_clip, grayscaleRange);
title('Zoomed');

%% Compare segmentation

% grayscale values of masks for Users 1 and 2
mask_User1 = image_User1_clip == 1666;
mask_User2 = image_User2_clip == 2359;

% show
ax1 = gobjects(1, 3);
figure('Name', 'Segmentation', 'Color', 'w');
ax1(1) = subplot(1, 3, 1);
imshow(image_User1_clip, grayscaleRange);
title('User1');
ax1(2) = subplot(1, 3, 2);
imshow(image_User2_clip, grayscaleRange);
title('User2');
ax1(3) = subplot(1, 3, 3);
imshowpair(mask_User1, mask_User2, 'falsecolor'); % green and pink for diff
title('User1 vs User2');
% link for zooming
zoom('on');
linkaxes(ax1, 'xy');

%% compare

% mask differences
mask_yUser1_nUser2 = mask_User1 & ~mask_User2;
fprintf('User1 chose %d pixels that User2 did not choose\n', ...
        sum(mask_yUser1_nUser2, 'all'));
mask_nUser1_yUser2 = mask_User2 & ~mask_User1;
fprintf('User2 chose %d pixels that User1 did not choose\n', ...
        sum(mask_nUser1_yUser2, 'all'));

% grayscale values
grayscaleValues_User1         = image_slice_clip(mask_User1);
grayscaleValues_User2         = image_slice_clip(mask_User2);
grayscaleValues_yUser1_nUser2 = image_slice_clip(mask_yUser1_nUser2);

% convert grayscale to hounsfield units (HU)
% https://en.wikipedia.org/wiki/Hounsfield_scale
gray2HU = @(im) int16(im) - 1024; % cast to signed to allow for negative values

hounsfieldUnits_User1 = gray2HU(grayscaleValues_User1);
hounsfieldUnits_User2 = gray2HU(grayscaleValues_User2);
hounsfieldUnits_yUser1_nUser2 = sort(gray2HU(grayscaleValues_yUser1_nUser2));

% histogram bin edges
binEdges_grayscaleValues = linspace(0, 1000, 11);
binEdges_hounsfieldUnits = linspace(-1000, 0, 11);

% show
FA = 0.7; % FaceAlpha
figure('Name', 'Histograms', 'Color', 'w');
subplot(1, 2, 1); % Grayscale values
hold('on');
histogram(grayscaleValues_User1, binEdges_grayscaleValues, ...
          'DisplayName', 'User1', 'FaceAlpha', FA);
histogram(grayscaleValues_User2, binEdges_grayscaleValues, ...
          'DisplayName', 'User2', 'FaceAlpha', FA);
legend();
xlabel('Grayscale value');
ylabel('Count');
box('on');
subplot(1, 2, 2); % Hounsfield units
hold('on');
histogram(hounsfieldUnits_User1, binEdges_hounsfieldUnits, ...
          'DisplayName', 'User1', 'FaceAlpha', FA);
histogram(hounsfieldUnits_User2, binEdges_hounsfieldUnits, ...
          'DisplayName', 'User2', 'FaceAlpha', FA);
xlabel('Hounsfield units');
%ylabel('Count');
%legend();
box('on');
