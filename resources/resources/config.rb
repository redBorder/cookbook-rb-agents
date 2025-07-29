# Cookbook:: :: rb-agents
#
# Resource:: config
#

unified_mode true
actions :add, :remove, :register, :deregister
default_action :add

attribute :user, kind_of: String, default: 'root'
attribute :redborder_webui_base_url, kind_of: String, default: 'https://webui.service'
