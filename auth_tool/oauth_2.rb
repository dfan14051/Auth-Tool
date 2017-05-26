require_relative 'client'

module AuthTool
  module OAuth2
    ##
    # Returns redirect url for user authentication with the service
    #
    # @param [AuthTool::Client] client
    #   The AuthTool Client object.
    #
    # @return [String] The url to redirect to.
    def self.redirect_url client
      url = client.signet.authorization_uri
      return url
    end

    ##
    # Handles OAuth 2.0 callback procedure
    # Called by AuthTool::receive.
    #
    # @param [AuthTool::Client] client
    #   The client containing the API information.
    #
    # @param [Hash] response
    #   The response to the callback url (authentication token).
    def self.receive(client, response)
      client.signet.code = response["code"] if response.has_key?("code")
      client.signet.code = response[:code] if response.has_key?(:code)
      client.signet.fetch_access_token!
    end

    ##
    # Makes an authenticated call to the API resource.
    # Called by AuthTool::call.
    #
    # @param [AuthTool::Client] client
    #   The client containing the API information.
    #
    # @param [String] uri
    #   The API endpoint to hit.
    #
    # @param [Hash] params
    #   Hash of additional parameters for the call.
    #
    # @return [Hash] The endpoint's response.
    #
    def self.call(client, uri, params)
      header = params.delete('header') if params.has_key? 'header'
      body = params.delete('body') if params.has_key? 'body'
      conn = AuthTool::Helper.get_connection(params)
      options = {:header => header, :body => body, :uri => uri, :connection => conn}
      response = client.signet.fetch_protected_resource(options)
      return JSON.parse(response.body)
    end
  end
end
