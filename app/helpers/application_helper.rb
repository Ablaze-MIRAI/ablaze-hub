module ApplicationHelper
  def get(url)
    cookie_string = cookies.map { |k, v| "#{k}=#{v}" }.join("; ")
    HTTP.headers("Cookie" => cookie_string)
        .headers(:accept => "application/json")
        .get(url)
  end

  def post(url, body)
    HTTP
      .headers("Content-Type" => "application/json")
      .headers("X-Forwarded-For" => request.remote_ip)
      .headers("User-Agent" => request.user_agent)
      .headers("Cookie" => cookies.map { |k, v| "#{k}=#{v}" }.join("; "))
      .post(url, :json => body)
  end

  def get_variant_core(min, max, excluded = [])
    variant = rand(min..max)
    if excluded.include?(variant)
      variant = get_variant_core(min, max, excluded)
    end
    variant
  end

  def get_variant(min, max, excluded = [])
    variant = get_variant_core(min, max, excluded)
    "variant#{variant < 10 ? '0' : ''}#{variant}"
  end

  def append_params(url, params)
    return url if params.nil?

    params.each do |key, value|
      next if value.nil?

      url += url[-1] == '?' ? '' : '&'
      url += "#{key}=#{value}"
    end
    url
  end

  def get_avatar_url
    scale = rand(70..139)
    background = lambda do
      colors = %w[b6e3f4 c0aede d1d4f9 ffd5dc ffdfbf ecad80]
      colors.sample
    end
    eyebrows = get_variant(1, 15)
    eyes = get_variant(1, 26)
    glasses = get_variant(1, 5)
    glasses_probability = rand(100)
    mouth = get_variant(1, 30, [13, 11, 6])
    url = "https://api.dicebear.com/8.x/adventurer-neutral/svg?"
    params = {
      scale: scale,
      backgroundColor: background.call,
      eyebrows: eyebrows,
      eyes: eyes,
      mouth: mouth,
      glasses: glasses,
      glassesProbability: glasses_probability
    }
    url = append_params(url, params)
    url
  end
end
