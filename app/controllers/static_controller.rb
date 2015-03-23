class StaticController < ApplicationController
  skip_before_filter :authenticate_token

  def index
    render "index"
  end

  def app
    render "app", layout: "angular"
  end

  def login
    redirect_to "/app#/login"
  end

end
