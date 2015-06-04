Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}",
    password: ENV['REDIS_PASSWORD'],
    namespace: "sidekiq_mylab_#{Rails.env}"
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}",
    password: ENV['REDIS_PASSWORD'],
    namespace: "sidekiq_mylab_#{Rails.env}"
  }
end
