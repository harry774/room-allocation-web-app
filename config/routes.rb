Rails.application.routes.draw do
  get 'home/index'
  match 'home/import', via: [ :post]
  get 'home/result'
end
