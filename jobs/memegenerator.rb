require 'net/http'
require 'json'

#Id of the widget
id = "memegenerator"

#The Memegenerator API
server = "http://version1.api.memegenerator.net"

proxy_addr = 'proxy'
proxy_port = 3128

SCHEDULER.every '1m', :first_in => 0 do |job|
  Net::HTTP.new("version1.api.memegenerator.net", nil, proxy_addr, proxy_port).start { |http|
    uri = URI(URI.encode("#{server}/Instances_Select_ByPopular?languageCode=en&pageIndex=0&pageSize=12&days=1"))

    res = http.get(uri)

    #Marshal the json into an object
    j = JSON.parse(res.body)

    #We want a random result
    instances = j["result"].shuffle
    imageUrl = instances[0]["instanceImageUrl"]

    #Send the meme to the image widget
    send_event(id, { image: "#{imageUrl}" })
  }
end
