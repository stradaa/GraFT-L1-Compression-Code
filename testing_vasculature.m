ename = '23.Mar.2020_10.45.01_TB013120M4_PwrG80R75_dualpuff_0.16Hz_dualCH';
skel_label = importdata(strcat(ename,'_reg_skel_label_ves.mat'));
mask_ind   = importdata(strcat(ename,'_reg_mask_ind_ves.mat'));
mask       = importdata(strcat(ename,'_reg_mask_ves.mat'));

labelmap = zeros(size(mask));
labelmap(mask_ind) = skel_label;
figure;imagesc(labelmap)

% loading GraFT results
load('vasculature_10_dict_v4.mat');  n = 4;  % 5 ROIs

result = zeros(size(labelmap,1), size(labelmap,2), size(S,2));
% logical mask of valid indices
valid_mask = labelmap > 0;
valid_indices = labelmap(valid_mask);

% index into S using the valid indices
mapped_values = S(valid_indices, :);  % This is a [#valid_positions x 10] array

lin_indices = find(valid_mask);

for i = 1:size(S,2)
    layer = zeros(size(labelmap));
    layer(lin_indices) = mapped_values(:, i);
    result(:,:,i) = layer;
end

% Viewing Results
Sthresh = result;
for ll = 1:size(Sthresh,3)
    Sthresh(:,:,ll) = Sthresh(:,:,ll).*(Sthresh(:,:,ll) > 0.05*max(max(Sthresh(:,:,ll),[],1), [], 2));
end
MovieSlider(Sthresh);title(sprintf('ROIs -v%i', n));

%%
new_img = plotDifferentColoredROIS(result);
fig = figure('Color', 'w', 'Visible', 'on', 'Position', [20 20 (352+20)*2, 2*(420+20)]);
imagesc(new_img)
axis tight; 
axis xy; axis off;

%%
roi_num = 5;
sampling_rate = 4; % Hz
total_time = size(dict_out,1) / sampling_rate; % 555.75 seconds
time_scale = 50; % Time scale in seconds for reference

fig = figure('Color', 'w', 'Position', [20 20 2000 500], 'Visible', 'on');
colors_rois = {[0,0,1], [1,0,0], [0,1,0], [1,0.1034,0.7241], [1,0.8276,0]};
tiledlayout(roi_num, 1);
for i = 1:roi_num
    nexttile(i);
    if i ==5
        plot(dict_out(:,i)+0.05, 'Color', colors_rois{i}, 'LineWidth',1.5);
    else
        plot(dict_out(:,i), 'Color', colors_rois{i}, 'LineWidth',1.5);
    end        
    % ylabel(sprintf('ROI %i', i))
    axis off
    axis tight
    ylim([0 0.2])
    % title(sprintf('ROI %i', i))
end
% add time reference
nexttile(roi_num);
hold on;
x_scale = [0, time_scale * sampling_rate]; % Convert seconds to samples
y_scale = [0, 0]; % Adjust y-position to keep it visible
plot(x_scale, y_scale, 'k', 'LineWidth', 2); % Black line for time reference
% text(x_scale(1), y_scale(1) - 0.05, sprintf('%d sec', time_scale), 'FontSize', 15, 'Color', 'k');
hold off;

%%
% creating xcorrelation plots (spatial)
font_size = 17;

% new_S = result(:,:,1:5);
% spatialROI = reshape(new_S, [], size(new_S,3));

spatialROI = S(:,1:5);

corrSpatial = corrcoef(spatialROI);

figure('Position', [200, 200, 800, 600], 'Color', 'w')
imagesc(corrSpatial);
colorbar('FontSize', font_size);
axis square off
% title('Spatial Regions of Interest Pearson Correlation');

[nROI, ~] = size(corrSpatial);
for i = 1:nROI
    for j = 1:nROI
        text(j, i, sprintf('%.2f', corrSpatial(i,j)), ...
            'HorizontalAlignment', 'center', 'Color', 'k', 'FontSize', font_size);
    end
end
colormap sky
clim([-1, 1])
set(gca, 'YTick', [], 'XTick', [])
set(gca,'fontname','Arial')
% exportgraphics(ax,'spatial_vasculature_corr.png','Resolution',300)

%%
% temporal
corrTemporal = corrcoef(dict_out(:,1:5));
font_size = 17;

% Plot the temporal correlation matrix.
figure('Position', [200, 200, 800, 600], 'Visible', 'on', 'Color', 'w')
imagesc(corrTemporal);
c = colorbar('FontSize', font_size);
axis square off

% Optionally, annotate the plot with the correlation values.
[nComp, ~] = size(corrTemporal);
for i = 1:nComp
    for j = 1:nComp
        text(j, i, sprintf('%.2f', corrTemporal(i,j)), ...
            'HorizontalAlignment', 'center', 'Color', 'k', 'FontSize', font_size);
    end
end
colormap sky
% clim([-1, 1])
set(gca, 'YTick', [], 'XTick', [])
set(gca,'fontname','Arial')
% ax = gca;
% exportgraphics(ax,'temporal_vasculature_corr.png','Resolution',300)