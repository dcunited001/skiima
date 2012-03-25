
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