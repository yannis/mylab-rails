Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}",
    namespace: "sidekiq_mylab_#{Rails.env}"
  }
  if ENV['REDIS_PASSWORD']
    config.redis[:password] = ENV['REDIS_PASSWORD']
  end
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}",
    namespace: "sidekiq_mylab_#{Rails.env}"
  }
  if ENV['REDIS_PASSWORD']
    config.redis[:password] = ENV['REDIS_PASSWORD']
  end
end
