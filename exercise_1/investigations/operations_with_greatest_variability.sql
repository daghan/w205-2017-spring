SELECT  var_samp(mortality_scaled_score) AS mortality_variance,
        var_samp(readmission_scaled_score) AS readmission_variance,
        var_samp(scaled_wait_times) AS wait_times_variance
FROM hospitals_with_final_score;
