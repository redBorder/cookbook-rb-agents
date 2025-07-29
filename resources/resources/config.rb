# Cookbook:: :: rb-agents
#
# Resource:: config
#
unified_mode true
actions :add, :remove, :register, :deregister
default_action :add

attribute :user, kind_of: String, default: 'root'
attribute :redborder_webui_base_url, kind_of: String, default: 'https://webui.service'
attribute :llm_service, kind_of: String
attribute :anthropic_api_key, kind_of: String
attribute :google_gemini_api_key, kind_of: String
attribute :ollama_base_url, kind_of: String
attribute :openai_api_key, kind_of: String
