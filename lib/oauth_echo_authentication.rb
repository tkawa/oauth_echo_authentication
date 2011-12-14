require 'active_support/concern'
require 'open-uri'

module OauthEchoAuthentication
  extend ActiveSupport::Concern

  module ClassMethods
    # for instant
  end
  def authenticate_with_oauth_echo
    @provider = request.headers['X-Auth-Service-Provider'] || 'https://api.twitter.com/1/account/verify_credentials.json'
    credentials = request.headers['X-Verify-Credentials-Authorization']
    unless credentials && credentials =~ /\AOAuth\s+/
      head 400 # Bad Request
      return
    end
    res = OpenURI.open_uri(@provider, 'Authorization' => credentials)
    json = res.read
    res.close
    raise OpenURI::HTTPError.new(res.status.join(' '), res) unless res.status[0] == '200'
    @user = JSON.parse(json)
  rescue OpenURI::HTTPError => e
    render json: JSON.parse(e.io.read), status: e.io.status[0].to_i
    return
  end
end

ActionController::Base.send :include, OauthEchoAuthentication
