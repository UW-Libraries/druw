class AddShibbolethHeaders 
  def initialize app
    @app = app
  end

  def call env
    env["REMOTE_USER"] = ENV["REMOTE_USER"]
    env["eppn"] = env["REMOTE_USER"] 
    env["Shib-Application-ID"] = "shib-app-id" 
    env["Shib-Sessions-ID"] = "shib-session-id" 
    env["unscoped-affiliation"] = "foo;bar" 
    
    Rails.logger.info "REMOTE_USER set to: " + env["REMOTE_USER"]
    @status, @headers, @response = @app.call(env)
    [@status, @headers, @response]
  end
end
