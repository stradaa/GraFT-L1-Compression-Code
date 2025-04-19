%% Paths %%
saveDir  = '.';                                                % Set the path where the output should be saved to
installGraFT

%% Loading data %%
% Neurofinder data was cropped and processed using the GUI, but original 
% files can be downloaded using the following public repository links from
% OSF.io.

url_t210 = 'https://osf.io/download/6802d54342a476fce6cc4703/'; % 210x210x8000
url_t16 = ''; % to add
url_t80 = 'https://osf.io/download/6802d369557a552a12d5650e/'; % 80x80x8000
url_t65 = 'https://osf.io/download/6802d33a557a552a12d56502/'; % 65x65x2000

fn210 = 't210.mat';
fn160 = 't160.mat';
fn80 = 't80.mat';
fn65 = 't65.mat';

options = weboptions('Timeout', 60, 'ContentType', 'binary');

% This will load the files into your current directory
websave(fn210, url_t210, options);
% websave(fn160, url_t160, options);
websave(fn80, url_t80, options);
websave(fn65, url_t65, options);

% To download the full 512x512x8000 Neurofinder data used, you can
% uncomment the following lines

% fprintf('Loading Neurofinder data...\n')
% data.nam = 'neurofinder.02.00';                                            % Create the name of the data to check for
% if ~exist(data.nam,'file')                                                 % download file if it doesn't exist in the directory
%     fprintf('Neurofinder data not detected, downloading data now...\n')
%     url         = 'https://s3.amazonaws.com/neuro.datasets/challenges/neurofinder/neurofinder.02.00.zip';
%     filename    = 'neurofinder.02.00.zip';
%     outfilename = websave(filename,url);
%     unzip(filename);
%     clear url filename                                                     % Clear un-needed variables
% end
% 
% data.dirname = fullfile(data.nam, 'images');                               % Get the directory name
% data.files   = dir(fullfile(data.dirname,'*.tiff'));                       % Get all of  the filenames (look for tiff files)
% data.fname   = fullfile(data.dirname, data.files(1).name);                 % Create a full-file name to point to the first file (used to get movie sizes)
% data.Fsim    = imread(data.fname);                                         % Read in the first file
% data.Fsim    = zeros(size(data.Fsim,1),size(data.Fsim,2),...
%                                                     length(data.files));   % Initialize the data array
% 
% for ll = 1:length(data.files)
%     fname = fullfile(data.dirname, data.files(ll).name);
%     data.Fsim(:,:,ll) = imread(fname);
% end
% 
% data.Fsim = im2double(data.Fsim);
% clear ll fname                                                             % Clear intermediary variables
% fprintf('...done\n')

%% Parameters %%
Parameters = struct();
Parameters.nneg_dict = true;
Parameters.nonneg = true;
Parameters.patchGraFT = false;
Parameters.grad_type         = 'full_ls_cor';                % Default to optimizing a full optimization on all dictionary elements at each iteration
Parameters.maxiter           = 0.01;                         % Default the maximum iteration to whenever Delta(Dictionary)<0.01
Parameters.tolerance         = 1e-8;                         % Default tolerance for TFOCS calls is 1e-8
Parameters.likely_form       = 'gaussian';                   % Default to a gaussian likelihood ('gaussian' or 'poisson')
Parameters.step_s            = 1;                            % Default step to reduce the step size over time (only needed for grad_type = 'norm')
Parameters.step_decay        = 0.995;                        % Default step size decay (only needed for grad_type = 'norm')
Parameters.max_learn         = 50;                           % Maximum number of steps in learning is 1000 
Parameters.learn_eps         = 5e-4;                         % Default learning tolerance: stop when Delta(Dictionary)<0.01
Parameters.verbose           = 0;                            % Default to no verbose output
Parameters.GD_iters          = 1;                            % Default to one GD step per iteration
Parameters.bshow             = 0;                            % Default to no plotting
Parameters.updateEmbed       = false;                        % Default to not updateing the graph embedding based on changes to the coefficients
Parameters.normalizeSpatial  = true;                         
Parameters.create_memmap     = false;

% Correlation kernel
correlation_kernel = struct();
correlation_kernel.w_time                   = 0;                            % Initialize the correlation kernel struct
correlation_kernel.reduce_dim               = true;                         % Default to reduce dimentions
correlation_kernel.corrType                 = 'embedding';                  % Set the correlation type to "graph embedding"

%% QUADPROG/MPC - testing %%
% Only loaded one at a time for each of the runs
load('t80.mat');
Parameters.n_dict = 10; % t65  -> 7, 
                        % t80  -> 10;
                        % t160 -> 28;
                        % t210 -> 40;

Parameters.solveUse = 'mpc'; % 'quadprog'

n = 12;
startLoop = tic;
run_times = zeros(n,1);
for i = 1:n
    startIteration = tic;
    [D,S] = GraFT(t80, [], correlation_kernel, Parameters);
    run_times(i) = toc(startIteration);
end
endLoop = toc(startLoop); % recorded and saved

%% PatchGraFT QUADPROG/MPC %%
% data used was the full 512 x 512 x 8000 neurofinder data. Recorded the
% average time of each patch with varying number of dictionary elements on
% 50 pixel by 50 pixel (default) patch window

Parameters.solveUse = 'mpc';        % 'quadprog'
n_dict = 2:10;

Parameters.patchGraFT = true;
Parameters.patchSize = [50,50];     % pixel x pixel
for i = n_dict
    [Sm,Dm] = patchGraFT(data.Fsim, i, [], correlation_Kernel, Parameters);
end
% iteration timings printed internally in pathGraFT


%% Optional: Viewing Results
Sthresh = S;
for ll = 1:size(Sthresh,3)
    Sthresh(:,:,ll) = Sthresh(:,:,ll).*(Sthresh(:,:,ll) > 0.05*max(max(Sthresh(:,:,ll),[],1), [], 2));
end
MovieSlider(Sthresh);
% clim([0, 1.3])
colormap gray

%% RESULTS & PLOTS 1 (Fig2A)
to_save = 1;

% MPC / Quadprog
sizes = {'210x210', '160x160', '80x80', '65x65'};
pixels = [210*210, 160*160, 80*80, 65*65];

% Normalized time per pixel
mpc_times = {
    [2082.6, 2082.9, 2086.4, 2094.1, 2089.3, 2097.7, 2075.8, 2074.3, 2077.9, 2075.9, 2080.0, 2072.5], ...
    [815.19, 817.07, 818.52, 817.03, 817.28, 818.20, 817.98, 820.00, 817.20, 815.33, 816.69, 816.79], ...
    [57.26, 56.27, 56.90, 56.79, 56.08, 56.26, 56.63, 56.93, 56.05, 55.93, 56.11, 55.89], ...
    [51.83, 31.87, 32.90, 32.97, 32.87, 32.91, 33.74, 34.79, 33.52, 32.92, 32.93, 32.67]
};
quadprog_times = {
    [2184.3, 2249.6, 2184.2, 2185.4, 2189.0, 2185.0, 2182.0, 2188.4, 2189.4, 2190.3, 2191.8, 2188.9], ...
    [895.95, 897.74, 904.17, 898.97, 901.17, 899.94, 899.34, 900.62, 900.63, 901.19, 899.77, 901.34], ...
    [84.54, 85.49, 85.97, 86.34, 85.78, 85.56, 85.06, 85.11, 85.51, 85.44, 85.41, 85.19], ...
    [62.84, 44.50, 43.36, 43.23, 43.31, 43.29, 43.81, 42.72, 42.78, 42.82, 42.83, 42.68]
};

% Compute normalized means and std errors
mpc_norm = cellfun(@(x, p) mean(x)/p, mpc_times, num2cell(pixels));
quad_norm = cellfun(@(x, p) mean(x)/p, quadprog_times, num2cell(pixels));

mpc_sem = cellfun(@(x, p) std(x)/sqrt(length(x))/p, mpc_times, num2cell(pixels));
quad_sem = cellfun(@(x, p) std(x)/sqrt(length(x))/p, quadprog_times, num2cell(pixels));

% Plot bars
data = [mpc_norm(:), quad_norm(:)];
errors = [mpc_sem(:), quad_sem(:)];

% Custom colors
mpc_color = [43, 45, 66] / 255;      % '#2B2D42'
quad_color = [0, 150, 199] / 255;    % '#0096C7'

% Plot
figure('Color', 'w', 'Visible', 'on');
bar_handle = bar(data, 'BarWidth', 0.9);

bar_handle(1).FaceColor = mpc_color;
bar_handle(2).FaceColor = quad_color;
hold on;
ngroups = size(data, 1);
nbars = size(data, 2);
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, data(:, i), errors(:, i), 'k', ...
        'linestyle', 'none', 'LineWidth', 1, 'CapSize', 7);
end

% Axes settings
set(gca, 'XTickLabel', sizes, 'FontSize', 14)
ylabel('Time (sec) per pixel', 'FontSize', 16, 'FontWeight', 'bold')
xlabel('Data Size', 'FontSize', 16, 'FontWeight', 'bold')
set(gca,'fontname','Arial')
legend({'MPC', 'Quadprog'}, 'FontSize', 14, 'Location', 'northeastoutside')
box off

if to_save
    saveas(gcf, 'figures/Fig2A.fig');
end

%% RESULTS & PLOTS 1 (Fig2C)
to_save = 1;

mpc_color = [43, 45, 66] / 255;     % '#2B2D42'
quad_color = [0, 150, 199] / 255;   % '#0096C7'

% Custom line styles
styles = {'-', '-'};

% Data setup
n_dict_vals = 2:10;
methods = {'MPC', 'Quadprog'};

% Time data
mpc_data = {
    [23.05, 22.94, 23.12, 16.30, 23.09, 22.32, 23.08, 23.00, 23.01, 23.05, 22.97, 23.02], ...
    [22.76, 23.57, 23.61, 23.72, 23.70, 23.68, 23.82, 23.93, 23.74, 23.70, 23.70, 23.66], ...
    [24.33, 24.04, 24.89, 24.66, 24.27, 24.36, 24.17, 24.23, 24.05, 24.24, 24.13, 24.87], ...
    [25.02, 24.75, 24.73, 24.97, 24.95, 24.80, 25.04, 24.78, 24.80, 24.85, 25.13, 24.88], ...
    [25.79, 25.40, 25.18, 25.51, 26.49, 25.55, 26.10, 25.79, 25.53, 25.44, 25.49, 25.53], ...
    [25.56, 25.57, 25.71, 25.93, 25.73, 26.10, 25.41, 25.36, 25.28, 25.32, 25.52, 25.47], ...
    [26.55, 26.19, 26.32, 26.41, 26.56, 26.41, 26.70, 26.49, 26.27, 26.15, 26.65, 26.65], ...
    [27.49, 27.03, 27.21, 27.33, 27.32, 27.33, 27.23, 27.08, 26.93, 27.10, 27.50, 27.45], ...
    [28.20, 27.83, 27.88, 28.08, 28.14, 28.14, 28.15, 28.36, 28.06, 28.10, 28.46, 26.16]
};

quad_data = {
    [25.30, 27.53, 22.17, 26.71, 26.30, 25.23, 25.53, 25.84, 25.14, 25.22, 14.90, 22.66], ...
    [29.21, 29.28, 29.41, 29.42, 29.74, 30.15, 29.97, 29.62, 29.64, 30.13, 30.42, 30.28], ...
    [30.19, 32.48, 31.80, 30.48, 30.59, 31.54, 30.51, 31.41, 30.93, 31.40, 31.61, 31.74], ...
    [33.24, 32.75, 33.04, 33.07, 33.37, 33.42, 33.71, 33.49, 33.42, 33.69, 34.50, 33.78], ...
    [32.31, 32.36, 32.33, 32.68, 32.90, 33.45, 33.86, 32.82, 32.80, 32.79, 33.79, 33.52], ...
    [33.30, 32.93, 33.37, 32.75, 32.67, 33.27, 33.21, 32.61, 32.37, 32.36, 32.98, 32.28], ...
    [34.15, 33.47, 33.58, 34.01, 34.21, 34.33, 34.12, 33.95, 33.32, 33.29, 34.33, 34.32], ...
    [35.61, 35.02, 35.11, 35.29, 35.60, 35.49, 35.73, 35.09, 35.04, 35.92, 35.82, 35.73], ...
    [37.16, 36.09, 36.23, 36.65, 36.97, 36.56, 36.77, 36.33, 36.22, 36.40, 37.13, 36.69]
};

% Precompute mean and std
mpc_mean = cellfun(@mean, mpc_data);
mpc_std = cellfun(@std, mpc_data);
quad_mean = cellfun(@mean, quad_data);
quad_std = cellfun(@std, quad_data);

% Plot
figure('Color','w', 'Visible', 'on');
hold on;

e1 = errorbar(n_dict_vals, mpc_mean, mpc_std, 'o-', ...
    'Color', mpc_color, 'LineStyle', '-', ...
    'LineWidth', 2, 'CapSize', 4, 'MarkerSize', 3, ...
    'DisplayName', 'MPC');

e2 = errorbar(n_dict_vals, quad_mean, quad_std, 'o--', ...
    'Color', quad_color, 'LineStyle', '-', ...
    'LineWidth', 2, 'CapSize', 4, 'MarkerSize', 3, ...
    'DisplayName', 'Quadprog');

legend('FontSize', 14, 'Location', 'northeastoutside', 'Box', 'off')

ax = gca;
set(gca,'fontname','Arial')
ax.LineWidth = 0.5;
ax.TickDir = 'in';
ax.FontSize = 14;
ax.XColor = 'k';
ax.YColor = 'k';
ax.YLim = [20 max(quad_mean + quad_std) + 2];
ax.XLim = [1, 11];
box off

if to_save
    saveas(gcf, 'figures/Fig2C.fig');
end