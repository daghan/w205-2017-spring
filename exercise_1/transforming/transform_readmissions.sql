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
