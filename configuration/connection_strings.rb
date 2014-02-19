module ConnectionStrings

  def mssql(db, tenant=nil)
    return db if db.is_a? String
    server = db[:server]
    server = "je-sql01-#{sql_environment_name}.je-labs.com" if server.nil?
    database_name = db[:database]
    database_name = "just-eat_#{tenant}" if database_name.nil?
    application_name = db[:app_name]
    application_name = @component_name if application_name.nil?
    connection = ""
    connection << "Application Name=#{application_name}; " unless application_name.nil?
    connection << "Server=#{server}; "
    connection << "Failover Partner=#{failover_partner(db)}; " unless failover_partner(db).nil?
    connection << "Database=#{database_name}; " unless database_name.nil?
    connection << "User Id=#{db[:username]}; " unless db[:username].nil?
    connection << "Password=#{db[:password]}; " unless db[:password].nil?
    connection << "Trusted_Connection=#{db[:trusted_connection]}; " unless db[:trusted_connection].nil?
    connection
  end

  def sql_environment_name
    return "qa16" if dev?
    name
  end

  private

  def failover_partner(db)
    if dev? || qa?
      return failover_partner_for_development_and_testing
    end
    fp = db[:failover_partner]
    return fp
  end

  def failover_partner_for_development_and_testing
    nil
  end
end
