class StaticController < ApplicationController

  def index
    render "index"
  end

  def app
    render "app", layout: "angular"
  end

  def login
    redirect_to "app#/login"
  end

end
