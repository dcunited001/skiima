DROP VIEW IF EXISTS test_view;
--=============
CREATE VIEW test_view AS (
  SELECT * FROM test_table
);