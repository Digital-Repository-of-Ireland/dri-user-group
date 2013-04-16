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

#Does not give error if it doesnt work