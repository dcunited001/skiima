DROP VIEW IF EXISTS test_view;
CREATE VIEW test_view AS (
  SELECT 
    id AS test_id, 
    name AS test_name 
  FROM test_table );