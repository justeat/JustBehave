module TeamCity
  def is_build_agent?
    not ENV['BUILD_NUMBER'].nil?
  end

  def tc_set_parameter(name, value)
    puts "##teamcity[setParameter name='#{name}' value='#{value}']"
  end
end
