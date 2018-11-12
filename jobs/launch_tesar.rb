require 'net/http'
require 'openssl'
require 'json'
require 'nokogiri'
require 'date'
require 'time'

def numeric?(lookAhead)
  lookAhead =~ /[[:digit:]]/
end

def getMenu()
  proxy_addr = 'proxy'
  proxy_port = 3128
	uri = URI.parse(URI.encode('https://www.menicka.cz/tisk.php?restaurace=3155'))
	http = Net::HTTP.new(uri.host, uri.port, proxy_addr, proxy_port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
	request = Net::HTTP::Get.new(uri.request_uri)
	response = http.request(request)

  page = Nokogiri::HTML(response.body)

  menu_day = page.css('div.content')[(Time.now() + 12*60*60).wday() - 1].text.strip
  haveday = true
  meal = Array.new()
  day = ""
  menu_day.each_line do |el|
    el = el.strip
    if el[-2] == "K"
      prize = -4
      while numeric?(el[prize]) == 0
        prize -= 1
      end
      el.insert(prize, ' ')
    end
    if el != ""
      if haveday
        day = el
        haveday = false
      else 
        meal.push(el.strip)
      end
    end
  end

  return { day: day, meal0: meal[0], meal1: meal[1], meal2: meal[2], meal3: meal[3] }

end

SCHEDULER.every '1m', :first_in => 0 do
  send_event("launch_tesar", getMenu())
end
