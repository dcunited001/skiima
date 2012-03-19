DROP TABLE IF EXISTS test_table;
CREATE TABLE test_table (
  id integer PRIMARY KEY,
  name varchar(40) NOT NULL CHECK (name <> ''));