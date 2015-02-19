class StaticController < ApplicationController

  def index
    render "index"
  end

  def app
    render "app", layout: "angular"
  end

end
