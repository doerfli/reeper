class ProfileController < ApplicationController

    def index
        @user = session[:userinfo]
    end

    def change_password
        @user = session[:userinfo]

        url = URI("https://#{AUTH0_CONFIG['auth0_domain']}/dbconnections/change_password")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        request = Net::HTTP::Post.new(url)
        request["content-type"] = 'application/json'
        request.body = "{\"client_id\": \"#{AUTH0_CONFIG['auth0_client_id']}\",\"email\": \"#{@user['email']}\",\"connection\": \"#{AUTH0_CONFIG['auth0_db_connection']}\"}"
        
        response = http.request(request)
        text = response.read_body

        if (response.code == '200')
            flash[:success] = text
        else 
            flash[:error] = text
        end
        
        redirect_to profile_path
    end

end