# Cookbook:: rbagents
#
# Provider:: config
#
action :add do
  begin
    redborder_webui_url = new_resource.redborder_webui_url
    user = new_resource.user

    dnf_package 'redborder-agents' do
      action :upgrade
      flush_cache[:before]
    end

    template '/opt/redborder-agents/redborder-agents/src/redborder_agents' do
      source 'env.erb'
      owner user
      group user
      mode '644'
      retries 2
      variables(
        redborder_webui_url: redborder_webui_url,
        log_file: log_file,
        s3_hostname: s3_hostname
      )
      cookbook 'rbagents'
      notifies :restart, 'service[redborder-agents]', :delayed
    end

    service 'redborder-agents' do
      service_name 'redborder-agents'
      ignore_failure true
      supports status: true, reload: true, restart: true
      action [:enable, :start]
    end

    Chef::Log.info('cookbook redborder-agents has been processed.')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service 'redborder-agents' do
      service_name 'redborder-agents'
      supports status: true, restart: true, start: true, enable: true, disable: true
      action [:disable, :stop]
    end
    Chef::Log.info('cookbook rb-agents has been processed.')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    unless node['redborder-agents']['registered']
      query = {}
      query['ID'] = "redborder-agents-#{node['hostname']}"
      query['Name'] = 'redborder-agents'
      query['Address'] = "#{node['ipaddress']}"
      query['Port'] = 443
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.default['redborder-agents']['registered'] = true
      Chef::Log.info('redborder-agents service has been registered to consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['redborder-agents']['registered']
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/redborder-agents-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.default['redborder-agents']['registered'] = false
      Chef::Log.info('redborder-agentsservice has been deregistered from consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end
