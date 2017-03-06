SELECT  corr(mortality_scaled_score, survey_scaled_score) AS mortality_survey_correlation,
        corr(readmission_scaled_score, survey_scaled_score) AS readmission_survey_correlation,
        corr(scaled_wait_times, survey_scaled_score) AS wait_times_survey_correlation
FROM hospitals_with_final_score;
