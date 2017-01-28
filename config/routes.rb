Rails.application.routes.draw do
  get 'call_concierges/pizza'

  get 'call_concierges/near'

  get 'call_concierges/inbound_call'

  get 'call_concierges/inboud_call_handler'

  get 'call_concierges/extension'

  get 'call_concierges/entry_code'

  root 'welcome#index'
end
