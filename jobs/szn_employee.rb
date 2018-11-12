require 'net/http'
require 'openssl'
require 'json'
require 'nokogiri'

def getEmployeeStatus(id)
	uri = URI.parse(URI.encode("{{ pillar['pass.neznam.url'] }}"))
	http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
	request = Net::HTTP::Get.new(uri.request_uri)
  request.add_field("{{ pillar['pass.neznam.post'] }}", "{{ pillar['pass.neznam.postauth'] }}")
	response = http.request(request)
  json = JSON.parse(response.body)
  {{ pillar['pass.neznam.condition'] }}
end

def getStatus()
  list = [{{ pillar['pass.neznam.id'] }}]
  employee = Array.new
  list.each { |id|
    status = getEmployeeStatus(id)
    if status != nil
      employee.push(status)
    end
  }
  return employee
end

#puts getStatus()

SCHEDULER.every '1m', :first_in => 0 do
  send_event("szn_employee", { szn_employee: getStatus() })
end
