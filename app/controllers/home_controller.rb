class HomeController < ApplicationController
  def index
    respond_to do |format|
      format.html {
        render html: bootstrap_index(params[:index_key]).html_safe
      }
    end
  end

private
  def bootstrap_index(index_key)
    redis = Redis.new(host: "129.194.56.70", password: "2NVMpacQdBNfb8WMHq2wnHgCPWvGMfoGoN2YdYYa4fKyjTiCmM")
    index_key ||= 'mylab:'
    byebug
    redis.get(index_key)
  end
end
