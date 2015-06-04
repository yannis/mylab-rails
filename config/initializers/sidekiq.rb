if Rails.env.production?

  Sidekiq.configure_server do |config|
    config.redis = {
      url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}",
      namespace: "sidekiq_mylab_#{Rails.env}",
      password: ENV['REDIS_PASSWORD']
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}",
      namespace: "sidekiq_mylab_#{Rails.env}",
      password: ENV['REDIS_PASSWORD']
    }
  end
end

else
  Sidekiq.configure_server do |config|
    config.redis = {
      url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}",
      namespace: "sidekiq_mylab_#{Rails.env}"
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}",
      namespace: "sidekiq_mylab_#{Rails.env}"
    }
  end
end
