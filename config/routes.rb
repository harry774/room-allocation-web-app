Rails.application.routes.draw do
  root to: 'home#index'
  match 'home/import', via: [ :post]
  get 'home/result'
end
