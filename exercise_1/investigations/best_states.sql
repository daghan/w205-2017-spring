SELECT state, avg(hospital_score) AS avg_hospital_score
FROM hospitals_with_final_score
GROUP BY state
ORDER BY avg_hospital_score DESC
LIMIT 10;
