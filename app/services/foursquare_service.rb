class FoursquareService
  def authenticate!(client_id, client_secret, code)
    resp = Faraday.get("https://foursquare.com/oauth2/access_token") do |req|
      req.params['client_id'] = client_id
      req.params['client_secret'] = client_secret
      req.params['grant_type'] = 'authorization_code'
      req.params['redirect_uri'] = "http://localhost:3000/auth"
      req.params['code'] = code
    end
    body = JSON.parse(resp.body)
    body["access_token"]
  end

  def friends(token)
    resp = Faraday.get("https://api.foursquare.com/v2/users/self/friends") do |req|
      req.params['oauth_token'] = token
      req.params['v'] = '20160201'
    end
    JSON.parse(resp.body)["response"]["friends"]["items"]
  end

  def foursquare(client_id, client_secret, zipcode)
    foursquare = {}

    resp = Faraday.get 'https://api.foursquare.com/v2/venues/search' do |req|
      req.params['client_id'] = client_id
      req.params['client_secret'] = client_secret
      req.params['v'] = '20160201'
      req.params['near'] = zipcode
      req.params['query'] = 'coffee shop'
    end

    body = JSON.parse(resp.body)

    if resp.success?
      foursquare[venues] = body["response"]["venues"]
    else
      foursquare[error] = body["meta"]["errorDetail"]
    end

    rescue Faraday::TimeoutError
      foursquare[error] = "There was a timeout. Please try again."

    foursquare
  end

  def create_tip(token, venueId, tip)
    resp = Faraday.post("https://api.foursquare.com/v2/tips/add") do |req|
      req.params['oauth_token'] = token
      req.params['v'] = '20160201'
      req.params['venueId'] = venueId
      req.params['text'] = tip
    end

  end

  def list_tips(token)
    resp = Faraday.get("https://api.foursquare.com/v2/lists/self/tips") do |req|
      req.params['oauth_token'] = token
      req.params['v'] = '20160201'
    end
    @results = JSON.parse(resp.body)["response"]["list"]["listItems"]["items"]
  end
end
