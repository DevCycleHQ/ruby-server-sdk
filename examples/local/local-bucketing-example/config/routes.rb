Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root to: "demo#index"
  get "/track", to: "demo#track"
  get "/flush_events", to: "demo#flush_events"
  get "/variable", to: "demo#variable"
end
