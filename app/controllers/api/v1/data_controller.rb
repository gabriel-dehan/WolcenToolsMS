class Api::V1::DataController < ApplicationController
  skip_before_action :authenticate!

  def eims
    parsed_files_manager = Wolcen::ParsedManager.new
    eims = parsed_files_manager.fetch(trees: :eims)

    render json: eims
  end

  def pst
    parsed_files_manager = Wolcen::ParsedManager.new
    pst = parsed_files_manager.fetch(trees: :pst)

    render json: pst
  end
end
