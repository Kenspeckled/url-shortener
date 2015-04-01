module Analytics

  @redis = Redis.new

  def self.add_to_visit_count(key)
    @redis.hincrby("key:#{key}", "visit_count", 1)
  end

end
