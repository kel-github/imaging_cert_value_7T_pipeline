plotmap = load('/data/VALCERT/derivatives/fmriprep/sub-124/ses-02/func/sub-124_ses-02_task-attlearn_run-3_desc-motion-physregress_timeseries.txt');

set(heatmap(plotmap), 'Colormap', hot)

% % Set a colormap that enhances contrast
% colormap('parula'); % You can choose other colormaps like 'jet', 'viridis', etc.
% 
% % Adjust color limits to emphasize differences
% minValue = min(plotmap(:));
% maxValue = max(plotmap(:));
% caxis([minValue maxValue]);

