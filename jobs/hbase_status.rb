require 'net/http'
require 'json'
require 'nokogiri'

HBASE_STATUS = Hash.new
HBASE_STATUS['test'] = ['http://test.cz:60010', 'http://test.cz:60010']

class HbaseCluster

  def initialize(cluster_name)
    @cluster_name = cluster_name
    @current_rs = 0
    @current_dead_rs = 0
    @current_rit = 0
    @json = getHbaseJson()
  end

  def getHbaseJson()
    i = 0
    while i < 2
      begin
        uri = URI.parse(HBASE_STATUS[@cluster_name][i] + "/jmx")
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        json = JSON.parse(response.body)
        json["beans"].each {|bean|
          if bean["name"] == "Hadoop:service=HBase,name=Master,sub=Server"
            if bean["tag.isActiveMaster"] == "true"
              return json
            else
              i += 1
            end
          end
        }
      rescue
        i += 1
      end
    end
    return i == 2 ? {} : json
  end

  def getStats()
    last_rs = @current_rs    
    last_dead_rs = @current_dead_rs    
    last_rit = @current_rit

    @json = getHbaseJson()

    @json["beans"].each {|bean|
      if bean["name"] == "Hadoop:service=HBase,name=Master,sub=Server"
        @current_rs = bean["numRegionServers"]
        @current_dead_rs = bean["numDeadRegionServers"]
      end
      if bean["name"] == "Hadoop:service=HBase,name=Master,sub=AssignmentManger"
        @current_rit = bean["ritCount"]
      end
    }

    return [{
      name: @cluster_name + '_hbase',
      items: {
        current_live: @current_rs, last_live: last_rs,
        current_dead: @current_dead_rs, last_dead: last_dead_rs,
        current_deco: @current_rit, last_deco: last_rit
      },
    }]
  end
end

fridex = HbaseCluster.new 'fridex'
skoks = HbaseCluster.new 'skoks'
skutr = HbaseCluster.new 'skutr'
cr = HbaseCluster.new 'cr'

#puts fridex.getStats()

#puts Time.now.strftime "%Y%m%dT%H:%M:%S%z"

SCHEDULER.every '1m', :first_in => 0 do
  for i in fridex.getStats()
    send_event(i[:name], i[:items])
  end
  for i in skoks.getStats()
    send_event(i[:name], i[:items])
  end
  for i in skutr.getStats()
    send_event(i[:name], i[:items])
  end
  for i in cr.getStats()
    send_event(i[:name], i[:items])
  end
end

