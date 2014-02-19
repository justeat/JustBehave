class NugetFeed
  def initialize(host='packages.je-labs.com', path='/nuget', name='Default', scheme='http')
    @host = host
    @path = path
    @name = name
    @scheme = scheme
  end

  def source
    "#{@scheme}://#{@host}#{@path}/#{@name}"
  end

  def to_s
    source
  end
end
