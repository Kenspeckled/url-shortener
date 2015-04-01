require 'redis'
class URLStore

  @redis = Redis.new

  def self.find(key)
    url_hash = @redis.hgetall("key:#{key}")
    return nil if url_hash.empty?
    url_hash
  end

  def self.set(args)
    name = args[:name]
    key = args[:key]
    target = args[:target]
    if !name or !key or !target
      raise "Not all values provided"
    end
    @redis.sadd("keys", key)
    @redis.hmset("key:#{key}", "name", name, "target", target, "created_at", Time.now)
  end

  def self.get_all
    @redis.smembers("keys").map do |key|
      url_hash = self.find(key)
      url_hash['key'] = key
      url_hash
    end
  end

end
