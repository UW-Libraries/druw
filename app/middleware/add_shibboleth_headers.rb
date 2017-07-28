class AddShibbolethHeaders 
  def initialize app
    @app = app
  end

  def call env
    env["Shib-Application-ID"] = "shib-app-id" 
    env["Shib-Sessions-ID"] = "shib-session-id" 
    env["affiliation"] = ENV["AFFILIATION"]
    env["uwNetID"] = ENV["UWNETID"]
    env["mail"] = ENV["MAIL"]
    env["eppn"] = ENV["EPPN"] 
    env["gws_groups"] = ENV["GWS_GROUPS"] 
    env["displayName"] = ENV["DISPLAYNAME"] 

    Rails.logger.info "USER set to: " + env["mail"]
    @status, @headers, @response = @app.call(env)
    [@status, @headers, @response]
  end
end
