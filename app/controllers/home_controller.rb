class HomeController < ApplicationController
  def index
    respond_to do |format|
      format.html {
        render html: bootstrap_index(params[:index_key]).try(:html_safe)
      }
    end
  end

private
  def bootstrap_index(index_key)
    redis = Redis.new(host: ENV['REDIS_HOST'], password: ENV["REDIS_PASSWORD"])
    index_key ||= redis.get('mylab:current')
    Rails.logger.debug "index_key: #{index_key}"
    redis.get(index_key)
  end
end
