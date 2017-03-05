-- According to:
-- Overall Hospital Quality Star Ratings on Hospital Compare
-- Methodology Report (v2.0)

-- Formula for hospital ranking

-- Mortality              (22.9%):  readmissions_parquet (subset), lower is better
-- Safety of Care         (22.9%):  ??? (ignore for this study but make a point)
-- Readmission            (22.9%):  readmissions_parquet (subset), lower is better
-- Patient Experience     (22.9%):  surveys_parquet, higher is better
-- Effectiveness of Care  (4.2%):   effective_care_parquet (subset) but we'll omit this since it is too hard
-- Timeliness of Care     (4.2%):   effective_care_parquet (subset), wait times, lower is better

-- Final formula: - (scaled_mortality * 0.22) - (scaled_readmissions * 0.22)
--                + (scaled_patient_surveys * 0.22)
--                - (scaled_timely_care * 4)



-- Mortality
-- First: Create a table of average mortality rates per hospital
DROP TABLE mortality_parquet;
CREATE TABLE mortality_parquet AS
SELECT provider_id, avg(score) AS avg_score
FROM readmissions_parquet
WHERE measure_id LIKE "MORT%" AND score IS NOT NULL
GROUP BY provider_id;
SELECT * FROM mortality_parquet LIMIT 2;
-- mean mortality
DROP TABLE mean_mortality;
CREATE TABLE  mean_mortality AS
SELECT avg(avg_score) as mean FROM mortality_parquet;
SELECT * FROM mean_mortality;
-- std mortality
DROP TABLE std_mortality;
CREATE TABLE  std_mortality AS
SELECT stddev_samp(avg_score) as std FROM mortality_parquet;
SELECT * FROM std_mortality;
-- scaled mortality scores
DROP TABLE final_mortality;
CREATE TABLE  final_mortality AS
SELECT * FROM (SELECT *, ((mort.avg_score - m.mean)/s.std) as scaled_score FROM mortality_parquet mort JOIN mean_mortality m JOIN std_mortality s) t;
SELECT * FROM final_mortality LIMIT 2;



-- readmissions
-- First: Create a table of average readmission rates per hospital
DROP TABLE readmissions_rate_parquet;
CREATE TABLE readmissions_rate_parquet AS
SELECT provider_id, avg(score) AS avg_score
FROM readmissions_parquet
WHERE measure_id LIKE "READM%" AND score IS NOT NULL
GROUP BY provider_id;
SELECT * FROM readmissions_rate_parquet LIMIT 2;
-- mean readmissions
DROP TABLE mean_readmissions;
CREATE TABLE  mean_readmissions AS
SELECT avg(avg_score) as mean FROM readmissions_rate_parquet;
SELECT * FROM mean_readmissions;
-- std readmissions
DROP TABLE std_readmissions;
CREATE TABLE  std_readmissions AS
SELECT stddev_samp(avg_score) as std FROM readmissions_rate_parquet;
SELECT * FROM std_readmissions;
-- scaled readmission scores
DROP TABLE final_readmissions;
CREATE TABLE  final_readmissions AS
SELECT * FROM (SELECT *, ((r.avg_score - m.mean)/s.std) as scaled_score FROM readmissions_rate_parquet r JOIN mean_readmissions m JOIN std_readmissions s) t;
SELECT * FROM final_readmissions LIMIT 2;



-- patient experince
-- First: Create a table of average patient experience rates per hospital
DROP TABLE patient_experience_parquet;
CREATE TABLE patient_experience_parquet AS
SELECT provider_id, avg(hcahps_base_score) AS avg_score
FROM surveys_parquet
WHERE hcahps_base_score IS NOT NULL
GROUP BY provider_id;
SELECT * FROM patient_experience_parquet LIMIT 2;
-- mean patient experience
DROP TABLE mean_patient_experience;
CREATE TABLE  mean_patient_experience AS
SELECT avg(avg_score) as mean FROM patient_experience_parquet;
SELECT * FROM mean_patient_experience;
-- std patient experience
DROP TABLE std_patient_experience;
CREATE TABLE  std_patient_experience AS
SELECT stddev_samp(avg_score) as std FROM patient_experience_parquet;
SELECT * FROM std_patient_experience;
-- scaled patient exprience
DROP TABLE final_patient_experience;
CREATE TABLE  final_patient_experience AS
SELECT * FROM (SELECT *, ((pe.avg_score - m.mean)/s.std) AS scaled_score FROM patient_experience_parquet pe JOIN mean_patient_experience m JOIN std_patient_experience s) t;
SELECT * FROM final_patient_experience LIMIT 2;



-- timeliness
-- We need to normalize all the wait times (T disribution)
-- First: We need the mean values for each measure
DROP TABLE mean_timely_care;
CREATE TABLE  mean_timely_care AS
SELECT measure_id, avg(score) as mean_score
FROM effective_care_parquet
WHERE score IS NOT NULL
GROUP BY measure_id;

-- Second: We need the unbiased standard deviation for each measure
DROP TABLE std_timely_care;
CREATE TABLE  std_timely_care AS
SELECT measure_id, stddev_samp(score) as std_score
FROM effective_care_parquet
WHERE score IS NOT NULL
GROUP BY measure_id;

SELECT * FROM mean_timely_care;
SELECT * FROM std_timely_care;

-- Now we can rescale the wait times for each procedure where the wait times
-- are reported. These incude "OP_3b","OP_5","OP_2","ED_1b","ED_2b","OP_18b","OP_20","OP_21"
-- Note that hospitals that didn't report wait times (score is NULL) are
-- punished with a default value of 1 (1 stardard deviation from the scaled mean Zero)
DROP TABLE timely_care;
CREATE TABLE  timely_care AS
SELECT * FROM (
      SELECT ec.provider_id as provider_id, ec.measure_id as mesure_id, ec.score as original_score,
      IF(ec.score IS NULL, 1, ((ec.score - mtc.mean_score)/stc.std_score)) AS scaled_wait_times,
      mtc.measure_id as mean_measure_id, mtc.mean_score, stc.std_score
      FROM effective_care_parquet ec
      LEFT JOIN mean_timely_care mtc ON ec.measure_id = mtc.measure_id
      LEFT JOIN std_timely_care stc ON ec.measure_id = stc.measure_id
      WHERE ec.measure_id IN ("OP_3b","OP_5","OP_2","ED_1b","ED_2b","OP_18b","OP_20","OP_21")
    ) t;

-- Lastly, we can take average of all the scaled and centered wait times
-- per each hospital. This will be our final timely care score.
-- Lower numbers are better

DROP TABLE final_timely_care;
CREATE TABLE final_timely_care AS
SELECT provider_id, avg(scaled_wait_times) AS avg_scaled_wait_time
FROM timely_care
GROUP BY provider_id;
SELECT * FROM final_timely_care LIMIT 10;



-- At this point we are ready to create our final hospital comparison TABLE
-- with the following Formula
-- Final formula: - (scaled_mortality * 0.229) - (scaled_readmissions * 0.229)
--                + (scaled_patient_surveys * 0.229) - (scaled_timely_care * 0.042)


DROP TABLE hospital_compare;
CREATE TABLE hospital_compare AS
SELECT * FROM (
    SELECT fm.provider_id AS provider_id, fm.scaled_score AS mortality_scaled_score,
    fa.scaled_score AS readmission_scaled_score,
    fp.scaled_score AS survey_scaled_score,
    ft.avg_scaled_wait_time AS scaled_wait_times,
    ( -(fm.scaled_score * 0.22) - (fa.scaled_score * 0.22)
      + (fp.scaled_score * 0.22) - (ft.avg_scaled_wait_time * 0.04)) AS hospital_score
    FROM final_mortality fm
      JOIN final_readmissions fa ON (fm.provider_id = fa.provider_id)
      JOIN final_patient_experience fp on (fm.provider_id = fp.provider_id)
      JOIN final_timely_care ft on (fm.provider_id = ft.provider_id)
    ) t;

-- All hospitals including the hospital_score according to the Formula
DROP TABLE hospitals_with_final_score;
CREATE TABLE hospitals_with_final_score AS
SELECT * FROM (
    SELECT hp.*,
    hc.mortality_scaled_score AS mortality_scaled_score,
    hc.readmission_scaled_score AS readmission_scaled_score,
    hc.survey_scaled_score AS survey_scaled_score,
    hc.scaled_wait_times AS scaled_wait_times,
    hc.hospital_score AS hospital_score
    FROM hospitals_parquet hp
    JOIN hospital_compare hc ON (hp.provider_id = hc.provider_id)
  ) t;

-- Top 10 hospitals in the country
select provider_id, hospital_name, hospital_score from hospitals_with_final_score ORDER BY hospital_score DESC limit 10;
