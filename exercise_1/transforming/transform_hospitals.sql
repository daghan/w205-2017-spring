-- The hospitals
DROP TABLE hospitals_parquet;
CREATE TABLE hospitals_parquet
AS SELECT *
FROM hospitals;
ALTER TABLE hospitals_parquet CHANGE provider_id provider_id BIGINT FIRST;
