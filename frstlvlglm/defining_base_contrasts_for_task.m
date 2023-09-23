% K. Garner, 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEED TO AMEND THIS TO INCLUDE THE DISPERSION AND ONSET DERIVATIVES!!!
% defining contrasts of interest for 
% certainty x tgt interaction
% main effect value config
% counterfactual - no conflict (or regret)
% counterfactual - conflict (or regret)

% design
% left vs right (tgt location)
% .5 vs .8 (cert)
% hh, hl, lh, ll (value)
% names = {
%     {'left_.5_hh'}    {'left_.5_hl'}    {'left_.5_lh'}    {'left_.5_ll'}    {'left_.8_hh'}    {'left_.8_hl'}    {'left_.8_lh'}    {'left_.8_ll'}    {'right_.5_hh'}
%     {'right_.5_hl'}    {'right_.5_lh'}    {'right_.5_ll'}    {'right_.8_hh'}    {'right_.8_hl'}    {'right_.8_lh'}    {'right_.8_ll'} }

% 16 task regressors x 3 HRF parameters = 48 total

% main effect of certainty left > right
% cond %tgtloc %cert %tgtlocxcert
% l5       1    -1     -1
% l8       1     1      1
% r5      -1    -1      1
% r8      -1     1     -1

cert_left = [-1 0 0 -1 0 0 -1 0 0 -1 0 0 1 0 0 1 0 0 1 0 0 1 0 0];
cert_right = [-1 0 0 -1 0 0 -1 0 0 -1 0 0 1 0 0 1 0 0 1 0 0 1 0 0];
cert_left = [cert_left, zeros([1, length(cert_left)])];
cert_right = [zeros(1, length(cert_right)), cert_right];

certbyloc = [-1 0 0 1 0 0 1 0 0 -1 0 0];
certbyloc = [repmat(certbyloc(1:3),1,4), ...
             repmat(certbyloc(4:6),1,4), ...
             repmat(certbyloc(7:9),1,4), ...
             repmat(certbyloc(10:12),1,4)];


% effect of left != right value vs left value == right value
% cond 
% a positive value for the first suggests that the
% voxel's activity is increased when high value is on the 
% left
% a positive value for the 2nd suggests that its actity is
% increased when high value is on the right.
% So, a voxel that cares about value in the left hemifield
% should be +/-
% hh   -0.5   -0.5        
% hl      1      0
% lh      0      1
% ll   -0.5   -0.5   
rel_val_left = [-0.5  0 0  1 0 0   0 0 0  -0.5 0 0];
rel_val_left = repmat(rel_val_left, 1, 4);
rel_val_right = [-0.5  0 0  0 0 0  1 0 0  -0.5 0 0];
rel_val_right = repmat(rel_val_right, 1, 4);

% counterfactual; no value conflict
% cond  tgt  cert  val tgt valxtgt
% hh     l    .5    1  1      1
% hl     l    .5    0  0      0
% lh     l    .5    0  0      0
% ll     l    .5   -1  1     -1
% hh     l    .8    1  1      1
% hl     l    .8    0  0      0
% lh     l    .8    0  0      0
% ll     l    .8   -1  1     -1
% hh     r    .5    1 -1     -1
% hl     r    .5    0  0      0
% lh     r    .5    0  0      0
% ll     r    .5   -1 -1      1
% hh     r    .8    1 -1     -1
% hl     r    .8    0  0      0
% lh     r    .8    0  0      0
% ll     r    .8   -1 -1      1 
cf_noconf = [1 0 0 0 0 0 0 0 0 -1 0 0 1 0 0 0 0 0 0 0 0 -1 0 0 -1 0 0 ...
             0 0 0 0 0 0 1 0 0 -1 0 0 0 0 0 0 0 0 1 0 0];

% counterfactual; value conflict
% cond  tgt  cert  val tgt valxtgt
% hh     l    .5    0  0      0
% hl     l    .5    1  1      1
% lh     l    .5   -1  1     -1
% ll     l    .5    0  0      0
% hh     l    .8    0  0      0
% hl     l    .8    1  1      1
% lh     l    .8   -1  1     -1
% ll     l    .8    0  0      0
% hh     r    .5    0  0      0
% hl     r    .5    1 -1     -1
% lh     r    .5   -1 -1      1
% ll     r    .5    0  0      0
% hh     r    .8    0  0      0
% hl     r    .8    1 -1     -1
% lh     r    .8   -1 -1      1
% ll     r    .8    0  0      0 
cf_conf = [0 0 0 1 0 0 -1 0 0 0 0 0 0 0 0 1 0 0 -1 0 0 0 0 0 0 0 0 -1 0 0 ...
           1 0 0 0 0 0 0 0 0 -1 0 0 1 0 0 0 0 0];

save('task_contrasts', 'cert_left', 'cert_right', 'certbyloc',...
    'rel_val_left', 'rel_val_right', 'cf_noconf', 'cf_conf');