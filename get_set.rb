require 'redis' 
class URLStore

  @redis = Redis.new

  def self.find(key)
    @redis.get(key)
  end

  def self.set(key, value)
    @redis.set(key, value)
  end

end
