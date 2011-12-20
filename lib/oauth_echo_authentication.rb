require 'active_support/concern'
require 'open-uri'

module OauthEchoAuthentication
  extend self

  WELLKNOWN_PROVIDERS = { :twitter => 'https://api.twitter.com/1/account/verify_credentials.json' }

  module ControllerMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def oauth_echo_authenticate_with(specified_provider, options = {})
        before_filter(options) do
          _oauth_echo_authenticate_with(specified_provider)
        end
      end
    end

    def _oauth_echo_authenticate_with(specified_provider)
      provider = request.headers['X-Auth-Service-Provider']
      raise AuthError.new('Unauthorized: provider not found', 401) unless provider
      unless provider == WELLKNOWN_PROVIDERS[specified_provider]
        raise AuthError.new('Forbidden: unsupported provider', 403)
      end
      @current_user = authenticate_with_oauth_echo!
    rescue OpenURI::HTTPError => e
      render :json => JSON.parse(e.io.read), :status => e.io.status[0].to_i
    rescue AuthError => e
      render :json => { :error => e.to_s }, :status => e.status
    end

    def authenticate_with_oauth_echo!
      provider = request.headers['X-Auth-Service-Provider']
      credentials = request.headers['X-Verify-Credentials-Authorization']
      unless provider && credentials && credentials =~ /\AOAuth\s+/
        raise AuthError.new('Unauthorized: invalid auth headers', 401)
      end
      OauthEchoAuthentication.authenticate(provider, credentials)
    end

    def authenticate_with_oauth_echo
      authenticate_with_oauth_echo! rescue nil
    end
  end

  def authenticate(provider, credentials)
    res = OpenURI.open_uri(provider, 'Authorization' => credentials)
    json = JSON.parse(res.read)
    res.close
    raise OpenURI::HTTPError.new(res.status.join(' '), res) unless res.status[0] == '200'
    json
  end

  class AuthError < StandardError
    def initialize(message, status)
      super(message)
      @status = status
    end
    attr_reader :status
  end
end

ActionController::Base.send :include, OauthEchoAuthentication::ControllerMethods
