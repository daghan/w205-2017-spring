-- The hospitals
DROP TABLE hospitals_parquet;
CREATE TABLE hospitals_parquet
AS SELECT *
FROM hospitals;
ALTER TABLE hospitals_parquet CHANGE provider_id provider_id BIGINT FIRST;


-- The surveys
DROP TABLE surveys_parquet;
CREATE TABLE surveys_parquet AS
SELECT provider_number, hcahps_base_score, hcahps_consistency_score
FROM surveys;
ALTER TABLE surveys_parquet CHANGE provider_number provider_id BIGINT FIRST;
ALTER TABLE surveys_parquet CHANGE hcahps_base_score hcahps_base_score BIGINT
AFTER provider_id;
ALTER TABLE surveys_parquet CHANGE hcahps_consistency_score hcahps_consistency_score BIGINT
AFTER hcahps_base_score;


-- The measures
DROP TABLE measures_parquet;
CREATE TABLE measures_parquet AS
SELECT *
FROM measures;


-- The effective care
DROP TABLE effective_care_parquet;
CREATE TABLE effective_care_parquet AS
SELECT provider_id, condition, measure_id, measure_name, score, sample,
  footnote, measure_start_date, measure_end_date
FROM effective_care;
ALTER TABLE effective_care_parquet CHANGE provider_id provider_id BIGINT FIRST;
ALTER TABLE effective_care_parquet CHANGE score score BIGINT AFTER measure_name;
ALTER TABLE effective_care_parquet CHANGE sample sample BIGINT AFTER score;


-- The readmissions
DROP TABLE readmissions_parquet;
CREATE TABLE readmissions_parquet AS
SELECT provider_id, measure_name, measure_id, compared_to_national,
  denominator, score, lower_estimate, higher_estimate, footnote,
  measure_start_date, measure_end_date
FROM readmissions;
ALTER TABLE readmissions_parquet CHANGE provider_id provider_id BIGINT FIRST;
ALTER TABLE readmissions_parquet CHANGE denominator denominator BIGINT
AFTER compared_to_national;
ALTER TABLE readmissions_parquet CHANGE score score DECIMAL(38,10) AFTER denominator;
ALTER TABLE readmissions_parquet CHANGE lower_estimate lower_estimate DECIMAL(38,10)
AFTER score;
ALTER TABLE readmissions_parquet CHANGE higher_estimate higher_estimate DECIMAL(38,10)
AFTER lower_estimate;


DESCRIBE hospitals_parquet;
DESCRIBE surveys_parquet;
DESCRIBE measures_parquet;
DESCRIBE effective_care_parquet;
DESCRIBE readmissions_parquet;


SELECT * FROM hospitals_parquet LIMIT 5;
SELECT * FROM surveys_parquet LIMIT 5;
SELECT * FROM measures_parquet LIMIT 5;
SELECT * FROM effective_care_parquet LIMIT 5;
SELECT * FROM readmissions_parquet LIMIT 5;
