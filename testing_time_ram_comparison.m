%% RESULTS & PLOTS 1 (Fig5A)
%% --- TIME Comparison Plot ---

% Data
tags1 = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024];
total_algo_time = [1.0000, 1.3068, 1.6061, 1.9107, 2.0151, 2.3796, 3.0920, 3.3442, 3.4095, 3.1655, 3.8246];
dict_update_time = [1.0000, 1.7115, 2.7543, 4.1121, 5.3198, 6.1427, 8.2053, 10.0607, 8.9100, 22.6171, 30.5666];

% Colors
c1 = [0, 150, 199] / 255;  % Total Algorithm Time
c2 = [43, 45, 66] / 255;   % Dictionary Update Time

% Plot
figure('Position', [100 100 800 600]);
hold on;

% Lines
semilogx(tags1, total_algo_time, '-', 'Color', c1, 'LineWidth', 2.5, 'DisplayName', 'Total Algorithm Time');
semilogx(tags1, dict_update_time, '-', 'Color', c2, 'LineWidth', 2.5, 'DisplayName', 'Dictionary Update Time');

% Stem overlays
for i = 1:length(tags1)
  
    plot([tags1(i), tags1(i)], [0, dict_update_time(i)], '--', 'Color', c2, 'LineWidth', 1.5);
    plot(tags1(i), dict_update_time(i), 'o', 'MarkerEdgeColor', c2, 'MarkerFaceColor', c2, 'MarkerSize', 6);

    plot([tags1(i), tags1(i)], [0, total_algo_time(i)], '-', 'Color', c1, 'LineWidth', 1.5);
    plot(tags1(i), total_algo_time(i), 'o', 'MarkerEdgeColor', c1, 'MarkerFaceColor', c1, 'MarkerSize', 6);

end

% Aesthetics
ax = gca;
ax.XScale = 'log';
ax.FontSize = 17;
ax.TickDir = 'in';
set(gca,'fontname','Arial')
ax.LineWidth = 0.5;
box off
set(gcf, 'Color', 'w')

%% RESULTS & PLOTS 2 (Fig5B)
%% --- RAM Comparison Plot ---

% Data
tags2 = [1, 8, 64, 256, 512, 1024];
total_algo_ram = [1.0, 7.2279, 30.3391, 53.6274, 63.9344, 71.7248];
dict_update_ram = [1.0000, 6.3225, 29.3031, 48.9250, 58.0177, 66.7731];

% Colors swapped here
c1b = [43, 45, 66] / 255;   % Total Algorithm RAM
c2b = [0, 150, 199] / 255;  % Dictionary Update RAM

% Plot
figure('Position', [100 100 800 600]);
hold on;

% Lines
semilogx(tags2, total_algo_ram, '-', 'Color', c1b, 'LineWidth', 2.5, 'DisplayName', 'Total Algorithm RAM');
semilogx(tags2, dict_update_ram, '-', 'Color', c2b, 'LineWidth', 2.5, 'DisplayName', 'Dictionary Update RAM');

% Stem overlays
for i = 1:length(tags2)
    plot([tags2(i), tags2(i)], [0, total_algo_ram(i)], '--', 'Color', c1b, 'LineWidth', 1.5);
    plot(tags2(i), total_algo_ram(i), 'o', 'MarkerEdgeColor', c1b, 'MarkerFaceColor', c1b, 'MarkerSize', 6);
    
    plot([tags2(i), tags2(i)], [0, dict_update_ram(i)], '-', 'Color', c2b, 'LineWidth', 1.5);
    plot(tags2(i), dict_update_ram(i), 'o', 'MarkerEdgeColor', c2b, 'MarkerFaceColor', c2b, 'MarkerSize', 6);
end

% Aesthetics
ax = gca;
set(gca,'fontname','Arial')
ax.XScale = 'log';
set(gcf, 'Color', 'w')
ax.LineWidth = 0.5;
ax.FontSize = 17;
ax.TickDir = 'in';
box off