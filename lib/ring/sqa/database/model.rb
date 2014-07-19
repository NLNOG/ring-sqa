module Ring
class SQA
class Database

  class Ping < Sequel::Model
    set_schema do
      primary_key :id
      Time        :time
      String      :peer
      Fixnum      :latency
      String      :result
    end
    create_table unless table_exists?
  end

end
end
end
