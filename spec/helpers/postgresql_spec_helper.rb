# encoding: utf-8

# def create_test_db
#   ski = Skiima.new(:postgresql_test)
#   ski.up(:init_test_db)
# end

# def drop_test_db
#   ski = Skiima.new(:postgresql_test)
#   ski.down(:init_test_db)
# end

def ensure_closed(s, &block)
  yield s
ensure
  s.connection.close
end

def within_transaction(s, &block)
  s.connection.begin_db_transaction
  yield s
ensure
  s.connection.rollback_db_transaction
end