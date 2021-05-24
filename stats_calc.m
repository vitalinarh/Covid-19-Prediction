function stats = stats_calc(flag, is_multi, stats, r, idx_class)

    if (strcmp(flag, 'init') == 1)
        
        stats.error = [];

        stats.c1_sensitivity = [];
        stats.c1_specificity = [];

        stats.c2_sensitivity = [];
        stats.c2_specificity = [];
        
        if is_multi == 1
            stats.c3_sensitivity = [];
            stats.c3_specificity = [];
            stats.TP_c3 = [];
            stats.TN_c3 = [];
            stats.FP_c3 = [];
            stats.FN_c3 = [];
        end

        stats.TP_c1 = [];
        stats.TN_c1 = [];
        stats.FP_c1 = [];
        stats.FN_c1 = [];

        stats.TP_c2 = [];
        stats.TN_c2 = [];
        stats.FP_c2 = [];
        stats.FN_c2 = [];
        
    elseif (strcmp(flag, 'add') == 1)

        if is_multi == 1
            % CLASS 1
            TP = width(intersect(idx_class.idx_c1, idx_class.idx_c1_pred));
            TN = width(intersect(idx_class.idx_c2, idx_class.idx_c2_pred)) + width(intersect(idx_class.idx_c3, idx_class.idx_c3_pred));
            FP = width(intersect(idx_class.idx_c1, idx_class.idx_c2_pred)) + width(intersect(idx_class.idx_c1, idx_class.idx_c3_pred));
            FN = width(intersect(idx_class.idx_c2, idx_class.idx_c1_pred)) + width(intersect(idx_class.idx_c3, idx_class.idx_c1_pred));
            
            stats.TP_c1 = [stats.TP_c1 TP];
            stats.TN_c1 = [stats.TN_c1 TN];
            stats.FP_c1 = [stats.FP_c1 FP];
            stats.FN_c1 = [stats.FN_c1 FN];

            % CLASS 2
            TP = width(intersect(idx_class.idx_c2, idx_class.idx_c2_pred));
            TN = width(intersect(idx_class.idx_c1, idx_class.idx_c1_pred)) + width(intersect(idx_class.idx_c3, idx_class.idx_c3_pred));
            FP = width(intersect(idx_class.idx_c1, idx_class.idx_c2_pred)) + width(intersect(idx_class.idx_c3, idx_class.idx_c2_pred));
            FN = width(intersect(idx_class.idx_c2, idx_class.idx_c1_pred)) + width(intersect(idx_class.idx_c2, idx_class.idx_c3_pred));
            
            stats.TP_c2 = [stats.TP_c2 TP];
            stats.TN_c2 = [stats.TN_c2 TN];
            stats.FP_c2 = [stats.FP_c2 FP];
            stats.FN_c2 = [stats.FN_c2 FN];
            
            % CLASS 3
            TP = width(intersect(idx_class.idx_c3, idx_class.idx_c3_pred));
            TN = width(intersect(idx_class.idx_c1, idx_class.idx_c1_pred)) + width(intersect(idx_class.idx_c2, idx_class.idx_c2_pred));
            FP = width(intersect(idx_class.idx_c1, idx_class.idx_c3_pred)) + width(intersect(idx_class.idx_c2, idx_class.idx_c3_pred));
            FN = width(intersect(idx_class.idx_c3, idx_class.idx_c1_pred)) + width(intersect(idx_class.idx_c3, idx_class.idx_c2_pred));
            
            stats.TP_c3 = [stats.TP_c3 TP];
            stats.TN_c3 = [stats.TN_c3 TN];
            stats.FP_c3 = [stats.FP_c3 FP];
            stats.FN_c3 = [stats.FN_c3 FN];
            
        else
            % CLASS 1
            stats.TP_c1 = [stats.TP_c1 width(intersect(idx_class.idx_c1, idx_class.idx_c1_pred))];
            stats.TN_c1 = [stats.TN_c1 width(intersect(idx_class.idx_c2, idx_class.idx_c2_pred))];
            stats.FP_c1 = [stats.FP_c1 width(intersect(idx_class.idx_c1, idx_class.idx_c2_pred))];
            stats.FN_c1 = [stats.FN_c1  width(intersect(idx_class.idx_c2, idx_class.idx_c1_pred))];

            % CLASS 2
            stats.TP_c2 = [stats.TP_c2 width(intersect(idx_class.idx_c2, idx_class.idx_c2_pred))];
            stats.TN_c2 = [stats.TN_c2 width(intersect(idx_class.idx_c1, idx_class.idx_c1_pred))];
            stats.FP_c2 = [stats.FP_c2 width(intersect(idx_class.idx_c1, idx_class.idx_c2_pred))];
            stats.FN_c2 = [stats.FN_c2  width(intersect(idx_class.idx_c2, idx_class.idx_c1_pred))];
        end
        
    elseif strcmp(flag, 'calc') == 1
        %% Perform the calculations
        % Class 1
        % Sensitivity, TP / (TP + FN)
        stats.c1_sensitivity = [stats.c1_sensitivity (stats.TP_c1(r) / (stats.TP_c1(r) + stats.FN_c1(r)))];
        % Specificity, TN / (FP + TN)
        stats.c1_specificity = [stats.c1_specificity (stats.TN_c1(r) / (stats.FP_c1(r) + stats.TN_c1(r)))];

        % Class 2
        % Sensitivity, TP / (TP + FN)
        stats.c2_sensitivity = [stats.c2_sensitivity (stats.TP_c2(r) / (stats.TP_c2(r) + stats.FN_c2(r)))];
        % Specificity, TN / (FP + TN)
        stats.c2_specificity = [stats.c2_specificity (stats.TN_c2(r) / (stats.FP_c2(r) + stats.TN_c2(r)))];
        
        % Class 3
        % Sensitivity, TP / (TP + FN)
        stats.c3_sensitivity = [stats.c3_sensitivity (stats.TP_c3(r) / (stats.TP_c3(r) + stats.FN_c3(r)))];
        % Specificity, TN / (FP + TN)
        stats.c3_specificity = [stats.c3_specificity (stats.TN_c3(r) / (stats.FP_c3(r) + stats.TN_c3(r)))];

    elseif strcmp(flag, 'final_calc') == 1
        
        stats.TP_c1 = mean(stats.TP_c1);
        stats.TN_c1 = mean(stats.TN_c1);
        stats.FP_c1 = mean(stats.FP_c1);
        stats.FN_c1 = mean(stats.FN_c1);
        
        stats.c1_sensitivity = mean(stats.c1_sensitivity);
        stats.c1_specificity = mean(stats.c1_specificity);

        stats.TP_c2 = mean(stats.TP_c2);
        stats.TN_c2 = mean(stats.TN_c2);
        stats.FP_c2 = mean(stats.FP_c2);
        stats.FN_c2 = mean(stats.FN_c2);
        
        stats.c2_sensitivity = mean(stats.c2_sensitivity);
        stats.c2_specificity = mean(stats.c2_specificity);
        
        if is_multi == 1
            
            stats.TP_c3 = mean(stats.TP_c3);
            stats.TN_c3 = mean(stats.TN_c3);
            stats.FP_c3 = mean(stats.FP_c3);
            stats.FN_c3 = mean(stats.FN_c3);
            
            stats.c3_sensitivity = mean(stats.c3_sensitivity);
            stats.c3_specificity = mean(stats.c3_specificity);
        end

        stats.mean_error = mean(stats.error, 2);
        
    end
end