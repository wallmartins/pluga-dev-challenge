Rails.application.routes.draw do
  resources :summaries, only: [:create, :index, :show]
end
