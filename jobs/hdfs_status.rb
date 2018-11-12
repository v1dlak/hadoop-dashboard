require 'net/http'
require 'json'
require 'nokogiri'

HDFS_STATUS = Hash.new
HDFS_STATUS['test'] = ['http://test.cz:50070', 'http://test.cz:50070']

class Cluster

  def initialize(cluster_name)
    @cluster_name = cluster_name
    @current_live_nodes = 0
    @live_nodes = 0
    @dead_nodes = 0
    @deco_nodes = 0
  end

  def getHadoopStats()
    # getactive master
    i = 0
    while i < 2
      begin
        uri = URI.parse(HDFS_STATUS[@cluster_name][i] + "/dfshealth.jsp")
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        page = Nokogiri::HTML(response.body)
        if page.css('h1').text.split("(")[1] == "active)"
          break
        end
        i += 1
      rescue
        i += 1
      end
    end

    stats = Hash.new
    names = Array.new
    values = Array.new

    i = 0
    page.css('div.dfstable tr td#col1').each do |el|
      names[i] = el.text.strip.tr(' ','_') # this will also replace space with _
      i = i + 1
    end

    i = 0
    deco = 0
    page.css('div.dfstable tr td#col3').each do |el|
      el = el.text.strip
      if el.include? "Decommissioned"
        deco += el.split(" ")[2].split(")")[0].to_i
      end
      el = el.sub(/Decommissioned: \d*/,'') # I am not intrested in Decommissioned number
      values[i] = el.split
      i = i + 1
    end

    names.zip(values).each do |k, v|
      stats[k] = v
    end

    last_live_nodes = @live_nodes
    @live_nodes = stats['Live_Nodes'][0]
    last_dead_nodes = @dead_nodes
    @dead_nodes = stats['Dead_Nodes'][0]
    last_deco_nodes = @deco_nodes
    @deco_nodes = stats['Decommissioning_Nodes'][0].to_i + deco

    if (stats['Configured_Capacity'][0].to_f < stats['DFS_Used'][0].to_f)
      stats['DFS_Used'][0] = (stats['DFS_Used'][0].to_f / 1024.0).round(2).to_s
    end

    return [ {
      name: @cluster_name + '_dfs_usage',
      items: {
        min: 0,
        max: 100,
        title: stats['DFS_Used'][0] + ' of ' + stats['Configured_Capacity'][0] + stats['Configured_Capacity'][1],
        value: ( 100 / stats['Configured_Capacity'][0].to_f * stats['DFS_Used'][0].to_f).round(2)
      }
    }, {
      name: @cluster_name + '_dfs_nodes',
      items: {
        current_live: @live_nodes.to_i, last_live: last_live_nodes.to_i,
        current_dead: @dead_nodes.to_i, last_dead: last_dead_nodes.to_i,
        current_deco: @deco_nodes.to_i, last_deco: last_deco_nodes.to_i
      },
    }, {
      name: @cluster_name + '_live_nodes',
      items: { current: @live_nodes, last: last_live_nodes }
    }, {
      name: @cluster_name + '_dead_nodes',
      items: { current: @dead_nodes, last: last_dead_nodes }
    }, {
      name: @cluster_name + '_deco_nodes',
      items: { current: @deco_nodes, last: last_deco_nodes }
    } ]
  end

end

fernet = Cluster.new 'fernet'
fridex = Cluster.new 'fridex'
frisco = Cluster.new 'frisco'
skotch = Cluster.new 'skotch'
skutr = Cluster.new 'skutr'
skoks = Cluster.new 'skoks'
skyy = Cluster.new 'skyy'
cr = Cluster.new 'cr'

#puts fernet.getStats()

#puts Time.now.strftime "%Y%m%dT%H:%M:%S%z"

SCHEDULER.every '1m', :first_in => 0 do
  for i in fernet.getHadoopStats()
    send_event(i[:name], i[:items])
  end
  for i in fridex.getHadoopStats()
    send_event(i[:name], i[:items])
  end
  for i in frisco.getHadoopStats()
    send_event(i[:name], i[:items])
  end
  for i in skotch.getHadoopStats()
    send_event(i[:name], i[:items])
  end
  for i in skutr.getHadoopStats()
    send_event(i[:name], i[:items])
  end
  for i in skoks.getHadoopStats()
    send_event(i[:name], i[:items])
  end
  for i in skyy.getHadoopStats()
    send_event(i[:name], i[:items])
  end
  for i in cr.getHadoopStats()
    send_event(i[:name], i[:items])
  end
end

