class HomeController < ApplicationController
  before_filter :require_user
  def index
  end

  def new_features
  end

  def help
  end
end
