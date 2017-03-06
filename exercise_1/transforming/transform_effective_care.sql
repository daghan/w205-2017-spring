-- The effective care
DROP TABLE effective_care_parquet;
CREATE TABLE effective_care_parquet AS
SELECT provider_id, condition, measure_id, measure_name, score, sample,
  footnote, measure_start_date, measure_end_date
FROM effective_care;
ALTER TABLE effective_care_parquet CHANGE provider_id provider_id BIGINT FIRST;
ALTER TABLE effective_care_parquet CHANGE score score BIGINT AFTER measure_name;
ALTER TABLE effective_care_parquet CHANGE sample sample BIGINT AFTER score;
