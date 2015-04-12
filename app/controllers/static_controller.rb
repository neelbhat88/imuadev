class StaticController < ApplicationController
  respond_to :json, only: [:ping]
  
  def index
    render "index"
  end

  def app
    render "app", layout: "angular"
  end

  def login
    redirect_to "/app#/login"
  end

  def ping
    render status: 200, json: {ping: "pong"}
  end

end
