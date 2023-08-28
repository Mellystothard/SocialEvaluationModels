%Statistical Test using Wilcoxon Paired test to evaluate differences in BIC
%and LL between model versions 04b,08b,09b and 10b.

format short g

% Perform Wilcoxon paired test between BIC values for different models
[p0408, h0408, stats0408] = signrank(BIC_model04b, BIC_model08b);
[p0409, h0409, stats0409] = signrank(BIC_model04b, BIC_model09b);
[p0410, h0410, stats0410] = signrank(BIC_model04b, BIC_model10b);
[p0809, h0809, stats0809] = signrank(BIC_model08b, BIC_model09b);
[p0810, h0810, stats0810] = signrank(BIC_model08b, BIC_model10b);
[p0910, h0910, stats0910] = signrank(BIC_model09b, BIC_model10b);

% Display results
disp(['p-value (model04b vs. model08b): ' num2str(p0408)]);
disp(['p-value (model04b vs. model09b): ' num2str(p0409)]);
disp(['p-value (model04b vs. model10b): ' num2str(p0410)]);
disp(['p-value (model08b vs. model09b): ' num2str(p0809)]);
disp(['p-value (model08b vs. model10b): ' num2str(p0810)]);
disp(['p-value (model09b vs. model10b): ' num2str(p0910)]);

% Perform Wilcoxon paired test between LL values for different models
[p0408_LL, h0408_LL, stats0408_LL] = signrank(LL_model04b, LL_model08b);
[p0409_LL, h0409_LL, stats0409_LL] = signrank(LL_model04b, LL_model09b);
[p0410_LL, h0410_LL, stats0410_LL] = signrank(LL_model04b, LL_model10b);
[p0809_LL, h0809_LL, stats0809_LL] = signrank(LL_model08b, LL_model09b);
[p0810_LL, h0810_LL, stats0810_LL] = signrank(LL_model08b, LL_model10b);
[p0910_LL, h0910_LL, stats0910_LL] = signrank(LL_model09b, LL_model10b);

% Display results for LL
disp('Wilcoxon Paired Test Results for LL values:');
disp(['p-value (model04b vs. model08b): ' num2str(p0408_LL)]);
disp(['p-value (model04b vs. model09b): ' num2str(p0409_LL)]);
disp(['p-value (model04b vs. model10b): ' num2str(p0410_LL)]);
disp(['p-value (model08b vs. model09b): ' num2str(p0809_LL)]);
disp(['p-value (model08b vs. model10b): ' num2str(p0810_LL)]);
disp(['p-value (model09b vs. model10b): ' num2str(p0910_LL)]);

% Calculate means for BIC values just for ref
mean_BIC_model04b = mean(BIC_model04b);
mean_BIC_model08b = mean(BIC_model08b);
mean_BIC_model09b = mean(BIC_model09b);
mean_BIC_model10b = mean(BIC_model10b);

% Display results for BIC means
disp('Mean BIC Values for Different Models:');
disp(['Model04b: ' num2str(mean_BIC_model04b)]);
disp(['Model08b: ' num2str(mean_BIC_model08b)]);
disp(['Model09b: ' num2str(mean_BIC_model09b)]);
disp(['Model10b: ' num2str(mean_BIC_model10b)]);

% Calculate means for LL values
mean_LL_model04b = mean(LL_model04b);
mean_LL_model08b = mean(LL_model08b);
mean_LL_model09b = mean(LL_model09b);
mean_LL_model10b = mean(LL_model10b);

% Display results for LL means
disp('Mean LL Values for Different Models:');
disp(['Model04b: ' num2str(mean_LL_model04b)]);
disp(['Model08b: ' num2str(mean_LL_model08b)]);
disp(['Model09b: ' num2str(mean_LL_model09b)]);
disp(['Model10b: ' num2str(mean_LL_model10b)]);