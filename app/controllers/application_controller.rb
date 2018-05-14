class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  BING_IMAGE_SEARCH_URI="https://api.cognitive.microsoft.com"
  BING_IMAGE_SEARCH_PATH="/bing/v7.0/images/search"
end
