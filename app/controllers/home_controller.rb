class HomeController < ApplicationController
  def index
    @wall_records = Record.where.not(artwork_url: [ nil, "" ]).limit(20)
  end
end
