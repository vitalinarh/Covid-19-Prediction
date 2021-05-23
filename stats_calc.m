function stats = stats_calc(flag, stats, idx_c1, idx_c2, idx_c1_pred, idx_c2_pred, r)

    if (strcmp(flag, 'init') == 1)
        clear stats
        stats.error_fld = [];
        stats.error_mdc = [];

        stats.fld1_sensitivity = [];
        stats.fld1_specificity = [];

        stats.fld2_sensitivity = [];
        stats.fld2_specificity = [];

        stats.mdc1_sensitivity = [];
        stats.mdc1_specificity = [];

        stats.mdc2_sensitivity = [];
        stats.mdc2_specificity = [];

        stats.mdc_TP_released = [];
        stats.mdc_TN_released = [];
        stats.mdc_FP_released = [];
        stats.mdc_FN_released = [];

        stats.mdc_TP_not_released = [];
        stats.mdc_TN_not_released = [];
        stats.mdc_FP_not_released = [];
        stats.mdc_FN_not_released = [];

        stats.fld_TP_released = [];
        stats.fld_TN_released = [];
        stats.fld_FP_released = [];
        stats.fld_FN_released = [];

        stats.fld_TP_not_released = [];
        stats.fld_TN_not_released = [];
        stats.fld_FP_not_released = [];
        stats.fld_FN_not_released = [];
        
    elseif (strcmp(flag, 'add_fld') == 1)
        
        stats.fld_TP_released = [stats.fld_TP_released width(intersect(idx_c1, idx_c1_pred))];
        stats.fld_TN_released = [stats.fld_TN_released width(intersect(idx_c2, idx_c2_pred))];
        stats.fld_FP_released = [stats.fld_FP_released width(intersect(idx_c1, idx_c2_pred))];
        stats.fld_FN_released = [stats.fld_FN_released  width(intersect(idx_c2, idx_c1_pred))];
    
        stats.fld_TP_not_released = [stats.fld_TP_not_released width(intersect(idx_c2, idx_c2_pred))];
        stats.fld_TN_not_released = [stats.fld_TN_not_released width(intersect(idx_c1, idx_c1_pred))];
        stats.fld_FP_not_released = [stats.fld_FP_not_released width(intersect(idx_c1, idx_c2_pred))];
        stats.fld_FN_not_released = [stats.fld_FN_not_released  width(intersect(idx_c2, idx_c1_pred))];
        
    elseif strcmp(flag, 'add_mdc') == 1
        stats.mdc_TP_released = [stats.mdc_TP_released width(intersect(idx_c1, idx_c1_pred))];
        stats.mdc_TN_released = [stats.mdc_TN_released width(intersect(idx_c2, idx_c2_pred))];
        stats.mdc_FP_released = [stats.mdc_FP_released width(intersect(idx_c1, idx_c2_pred))];
        stats.mdc_FN_released = [stats.mdc_FN_released  width(intersect(idx_c2, idx_c1_pred))];

        stats.mdc_TP_not_released = [stats.mdc_TP_not_released width(intersect(idx_c2, idx_c2_pred))];
        stats.mdc_TN_not_released = [stats.mdc_TN_not_released width(intersect(idx_c1, idx_c1_pred))];
        stats.mdc_FP_not_released = [stats.mdc_FP_not_released width(intersect(idx_c1, idx_c2_pred))];
        stats.mdc_FN_not_released = [stats.mdc_FN_not_released  width(intersect(idx_c2, idx_c1_pred))];
        
    elseif strcmp(flag, 'calc_fld') == 1
        %% Perform the calculations
        % RELEASED
        % Sensitivity, TP / (TP + FN)
        stats.fld1_sensitivity = [stats.fld1_sensitivity (stats.fld_TP_released(r) / (stats.fld_TP_released(r) + stats.fld_FN_released(r)))];
        % Specificity, TN / (FP + TN)
        stats.fld1_specificity = [stats.fld1_specificity (stats.fld_TN_released(r) / (stats.fld_FP_released(r) + stats.fld_TN_released(r)))];

        % NOT RELEASED
        % Sensitivity, TP / (TP + FN)
        stats.fld2_sensitivity = [stats.fld2_sensitivity (stats.fld_TP_not_released(r) / (stats.fld_TP_not_released(r) + stats.fld_FN_not_released(r)))];
        % Specificity, TN / (FP + TN)
        stats.fld2_specificity = [stats.fld2_specificity (stats.fld_TN_not_released(r) / (stats.fld_FP_not_released(r) + stats.fld_TN_not_released(r)))];

    elseif strcmp(flag, 'calc_mdc') == 1
        %% Perform the calculations
        % RELEASED
        % Sensitivity, TP / (TP + FN)
        stats.mdc1_sensitivity = [stats.mdc1_sensitivity (stats.mdc_TP_released(r) / (stats.mdc_TP_released(r) + stats.mdc_FN_released(r)))];
        % Specificity, TN / (FP + TN)
        stats.mdc1_specificity = [stats.mdc1_specificity (stats.mdc_TN_released(r) / (stats.mdc_FP_released(r) + stats.mdc_TN_released(r)))];

        % RELEASED
        % Sensitivity, TP / (TP + FN)
        stats.mdc2_sensitivity = [stats.mdc2_sensitivity (stats.mdc_TP_not_released(r) / (stats.mdc_TP_not_released(r) + stats.mdc_FN_not_released(r)))];
        % Specificity, TN / (FP + TN)
        stats.mdc2_specificity = [stats.mdc2_specificity (stats.mdc_TN_not_released(r) / (stats.mdc_FP_not_released(r) +  stats.mdc_TN_not_released(r)))];
    
    elseif strcmp(flag, 'final_calc') == 1
        stats.mdc_TP_released = mean(stats.mdc_TP_released);
        stats.mdc_TN_released = mean(stats.mdc_TN_released);
        stats.mdc_FP_released = mean(stats.mdc_FP_released);
        stats.mdc_FN_released = mean(stats.mdc_FN_released);

        stats.mdc_TP_not_released = mean(stats.mdc_TP_not_released);
        stats.mdc_TN_not_released = mean(stats.mdc_TN_not_released);
        stats.mdc_FP_not_released = mean(stats.mdc_FP_not_released);
        stats.mdc_FN_not_released = mean(stats.mdc_FN_not_released);

        stats.mdc1_sensitivity = mean(stats.mdc1_sensitivity);
        stats.mdc1_specificity = mean(stats.mdc1_specificity);

        stats.mdc2_sensitivity = mean(stats.mdc2_sensitivity);
        stats.mdc2_specificity = mean(stats.mdc2_specificity);

        stats.fld_TP_released = mean(stats.fld_TP_released);
        stats.fld_TN_released = mean(stats.fld_TN_released);
        stats.fld_FP_released = mean(stats.fld_FP_released);
        stats.fld_FN_released = mean(stats.fld_FN_released);

        stats.fld_TP_not_released = mean(stats.fld_TP_not_released);
        stats.fld_TN_not_released = mean(stats.fld_TN_not_released);
        stats.fld_FP_not_released = mean(stats.fld_FP_not_released);
        stats.fld_FN_not_released = mean(stats.fld_FN_not_released);

        stats.fld1_sensitivity = mean(stats.fld1_sensitivity);
        stats.fld1_specificity = mean(stats.fld1_specificity);

        stats.fld2_sensitivity = mean(stats.fld2_sensitivity);
        stats.fld2_specificity = mean(stats.fld2_specificity);

        stats.mean_error_fld = mean(stats.error_fld, 2);
        stats.mean_error_mdc = mean(stats.error_mdc, 2);
    end
end