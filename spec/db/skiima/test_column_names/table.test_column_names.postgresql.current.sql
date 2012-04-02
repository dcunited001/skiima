DROP TABLE IF EXISTS test_column_names;
CREATE TABLE test_column_names (
  id integer PRIMARY KEY,
  email character varying(255),
  encrypted_password character varying(128),
  reset_password_token character varying(255),
  reset_password_sent_at timestamp without time zone,
  remember_created_at timestamp without time zone,
  sign_in_count integer default 0,
  current_sign_in_at timestamp without time zone,
  last_sign_in_at timestamp without time zone,
  current_sign_in_ip character varying(255),
  last_sign_in_ip character varying(255),
  created_at timestamp without time zone not null,
  updated_at timestamp without time zone not null,
  alias character varying(255),
  first_name character varying(255),
  last_name character varying(255));