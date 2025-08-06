# Cookbook:: rb-agents
#
# Provider:: config
#
action :add do
  begin
    # Resources definition
    user = new_resource.user
    redborder_webui_base_url = new_resource.redborder_webui_base_url
    model = new_resource.model
    anthropic_api_key = new_resource.anthropic_api_key
    gemini_api_key = new_resource.gemini_api_key
    ollama_base_url = new_resource.ollama_base_url
    openai_api_key = new_resource.openai_api_key

    # RPM Installation
    dnf_package 'redborder-agents' do
      action :upgrade
    end

    # This package is needed to install the correct
    # python version and python libraries.
    # It's also as Require in redborder-manager package.
    dnf_package 'redborder-pythonpyenv' do
      action :upgrade
    end

    # Templates
    template '/opt/redborder-agents/src/redborder_agents/.env' do
      source 'env.erb'
      owner user
      group user
      mode '644'
      retries 2
      variables(
        redborder_webui_base_url: redborder_webui_base_url,
        model: model,
        anthropic_api_key: anthropic_api_key,
        gemini_api_key: gemini_api_key,
        ollama_base_url: ollama_base_url,
        openai_api_key: openai_api_key
      )
      cookbook 'rb-agents'
      notifies :restart, 'service[redborder-agents]', :delayed
      only_if { ::Dir.exist?('/opt/redborder-agents/src/redborder_agents/') }
    end

    # Services
    service 'redborder-agents' do
      service_name 'redborder-agents'
      ignore_failure true
      supports status: true, reload: true, restart: true
      action [:enable, :start]
    end

    Chef::Log.info('cookbook rb-agents has been processed.')
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
  ipaddress = new_resource.ipaddress

  begin
    unless node['redborder-agents']['registered']
      query = {}
      query['ID'] = "redborder-agents-#{node['hostname']}"
      query['Name'] = 'redborder-agents'
      query['Address'] = ipaddress
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
