require 'devise/strategies/token_authenticatable'

Devise::Strategies::TokenAuthenticatable.class_eval do
  def authenticate!
    logger.debug("Overriden authenticate! in devise TokenAuthenticatable strategy")
    
    resource = mapping.to.find_for_token_authentication(authentication_hash)
    return fail(:invalid_token) if resource.nil? or resource.token_expired?

    if validate(resource)
      resource.after_token_authentication
      success!(resource)
    end
  end
end

#Check HTTP authentication
#Check why it logs in and not stateless, where does it review the api_key?
  #I dont think it does, if it creates a session (does it timeout?)
#Does not give error if it doesnt work