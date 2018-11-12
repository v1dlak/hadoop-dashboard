require 'net/http'
require 'json'
require 'nokogiri'
require 'date'

YARN_STATUS = Hash.new
YARN_STATUS['test'] = ['http://test.cz:8088', 'http://test.cz:8088']

class Cluster

  def initialize(cluster_name)
    @cluster_name = cluster_name
    @current_running_jobs = {}
    @current_failed_jobs = {}
    @live_nodes = 0
    @dead_nodes = 0
    @deco_nodes = 0
    @json_nodes = getJson("nodes")
    @json_apps = getJson("apps")
  end

  def getJson(what)
    i = 0
    while i < 2
      begin
        uri = URI.parse(YARN_STATUS[@cluster_name][i] + "/ws/v1/cluster/" + what)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        json = JSON.parse(response.body)
      rescue
        i += 1
      else
        break
      end
    end
    return i == 2 ? {} : json
  end

  def getCountLiveNodes()
    return @json_nodes['nodes']['node'].count{ |node| node['state'] == "RUNNING" }
  end

  def getCountLostNodes()
    return @json_nodes['nodes']['node'].count{ |node| node['state'] == "LOST" }
  end

  def getCountUnhealthyNodes()
    return @json_nodes['nodes']['node'].count{ |node| node['state'] == "UNHEALTHY" }
  end

  def getRunningApps()
    running_jobs = Array.new
    @json_apps['apps']['app'].each{ |app|
      if app['state'] == "RUNNING"
        running_jobs.push({
          name: app['name'],
          type: app['applicationType'],
          user: app['user'],
          start_time: Time.at(app['startedTime'] / 1000).strftime("%Y%m%dT%H:%M:%S%z")
        })
      end
    }
    return running_jobs
  end

  def getLastSuccessRun(name, type)
    lastsuccess = 0
    if type == "Samza"
      @json_apps['apps']['app'].each{ |app|
        if app['name'] == name and app['state'] == "RUNNING" and app['startedTime'] > lastsuccess
          lastsuccess = app['startedTime']
        end
      }
    else
      @json_apps['apps']['app'].each{ |app|
        if app['name'] == name and app['finalStatus'] == "SUCCEEDED" and app['finishedTime'] > lastsuccess
          lastsuccess = app['finishedTime']
        end
      }
    end
    return lastsuccess != 0 ? Time.at(lastsuccess / 1000).strftime("%Y%m%dT%H:%M:%S%z") : nil
  end

  def getFailedApps(hours)
    failed_jobs = Array.new
    time = (Time.now.to_i - hours * 60 * 60) * 1000
    @json_apps['apps']['app'].each{ |app|
      if (app['state'] == "FAILED" or app['finalStatus'] == "FAILED") and app['finishedTime'] > time
        failed_jobs.push({
          name: app['name'],
          last_run: Time.at(app['finishedTime'] / 1000).strftime("%Y%m%dT%H:%M:%S%z"),
          last_success_run: getLastSuccessRun(app['name'], app['applicationType'])
        })
      end
    }
    return failed_jobs
  end

  def getStats()
    @json_nodes = getJson("nodes")
    @json_apps = getJson("apps")
    last_running_jobs = @current_running_jobs.count()
    @current_running_jobs = getRunningApps()
    last_failed_jobs = @current_failed_jobs.count()
    if Date.today().wday() == 1
      @current_failed_jobs = getFailedApps(72)
    else
      @current_failed_jobs = getFailedApps(24)
    end
    last_live_nodes = @live_nodes
    @live_nodes = getCountLiveNodes()
    last_dead_nodes = @dead_nodes
    @dead_nodes = getCountLostNodes()
    last_deco_nodes = @deco_nodes
    @dead_nodes = getCountUnhealthyNodes()

    return [{
      name: @cluster_name + '_running_jobs',
      items: { current: @current_running_jobs.count(), last: last_running_jobs }
    }, {
      name: @cluster_name + '_running_jobs_list',
      items: { current: @current_running_jobs.count(), last: last_running_jobs, jobs: @current_running_jobs }
    }, {
      name: @cluster_name + '_failed_jobs',
      items: { current: @current_failed_jobs.count(), last: last_failed_jobs }
    }, {
      name: @cluster_name + '_failed_jobs_list',
      items: { current: @current_failed_jobs.count(), last: last_failed_jobs, jobs: @current_failed_jobs }
    }, {
      name: @cluster_name + '_yarn_live_nodes',
      items: { current: @live_nodes, last: last_live_nodes }
    }, {
      name: @cluster_name + '_yarn_nodes',
      items: {
        current_live: @live_nodes, last_live: last_live_nodes,
        current_dead: @dead_nodes, last_dead: last_dead_nodes,
        current_deco: @deco_nodes, last_deco: last_deco_nodes
      },
    }]
  end
end

fernet = Cluster.new 'fernet'
fridex = Cluster.new 'fridex'
frisco = Cluster.new 'frisco'
skotch = Cluster.new 'skotch'
skutr = Cluster.new 'skutr'
skyy = Cluster.new 'skyy'
cr = Cluster.new 'cr'

#puts fridex.getStats()

#puts Time.now.strftime "%Y%m%dT%H:%M:%S%z"

SCHEDULER.every '1m', :first_in => 0 do
  for i in fernet.getStats()
    send_event(i[:name], i[:items])
  end
  for i in fridex.getStats()
    send_event(i[:name], i[:items])
  end
  for i in frisco.getStats()
    send_event(i[:name], i[:items])
  end
  for i in skotch.getStats()
    send_event(i[:name], i[:items])
  end
  for i in skutr.getStats()
    send_event(i[:name], i[:items])
  end
  for i in skyy.getStats()
    send_event(i[:name], i[:items])
  end
  for i in cr.getStats()
    send_event(i[:name], i[:items])
  end
end

