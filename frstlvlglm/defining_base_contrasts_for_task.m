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

% main effect of certainty
% cond %tgtloc %cert %tgtlocxcert
% l5       1     1      1
% l8       1    -1     -1
% r5      -1     1     -1
% r8      -1    -1      1
k_mat = [1 1 1 1];
certbyloc = [1 -1 -1 1];
certbyloc = kron(certbyloc, k_mat);

% main effect of left vs right value
% cond v1  v2  v3
% hh    1   0  0
% hl   -1   1  0
% lh    0  -1  1
% ll    0   0 -1
me_val_conf = [1 -1  0  0;...
               0  1 -1  0;...
               0  0  1 -1];
me_val_conf = repmat(me_val_conf, 1, length(k_mat));
me_val_conf = me_val_conf / length(k_mat);

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
cf_noconf = [1 0 0 -1 1 0 0 -1 -1 0 0 1 -1 0 0 1]/4;

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
cf_conf = [0 1 -1 0 0 1 -1 0 0 -1 1 0 0 - 1 1 0]/4;

save('task_contrasts', 'certbyloc',...
    'me_val_conf', 'cf_noconf', 'cf_conf');