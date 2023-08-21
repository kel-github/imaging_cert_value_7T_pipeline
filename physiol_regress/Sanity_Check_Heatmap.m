
% matlabbatch{1}.spm.tools.physio.model.output_multiple_regressors = sprintf(
% %'sub-%s_ses-02_task-%s_run-%d_desc-motion-physregress_timeseries.txt'
% , sub, task, irun);

plotmap = load('/data/VALCERT/derivatives/fmriprep/sub-01/ses-02/func/sub-01_ses-02_task-attlearn_run-1_desc-motion-physregress_timeseries.txt');

set(heatmap(plotmap), 'Colormap', hot)

% % Set a colormap that enhances contrast
% colormap('parula'); % You can choose other colormaps like 'jet', 'viridis', etc.
% 
% % Adjust color limits to emphasize differences
% minValue = min(plotmap(:));
% maxValue = max(plotmap(:));
% caxis([minValue maxValue]);

