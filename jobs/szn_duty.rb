require 'net/http'
require 'openssl'
require 'json'
require 'nokogiri'

def getDuty(team)
	uri = URI.parse(URI.encode("{{ pillar['pass.puzzle.url'] }}"))
	http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
	request = Net::HTTP::Get.new(uri.request_uri)
	response = http.request(request)

	page = Nokogiri::HTML(response.body)

  admins = nil
  page.css('div.col-md-6 tr td.col-sm-4').each do |el|
    if admins
      return el.text.split(".")[0].capitalize
    end
    if el.text == team
      admins = true
    end
  end

end

SCHEDULER.every '1m', :first_in => 0 do
  send_event("szn_duty", { szn_duty_a6: getDuty("admins6"), szn_duty_ab1: getDuty("adminsbrno1") })
end
