DROP RULE IF EXISTS test_rule on test_view;
CREATE RULE test_rule AS 
ON DELETE TO test_view DO INSTEAD

DELETE FROM test_table tt
WHERE tt.id = OLD.test_id