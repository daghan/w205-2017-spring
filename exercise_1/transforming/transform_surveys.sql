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
