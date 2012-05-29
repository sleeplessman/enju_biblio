require "enju_biblio/engine"
require "enju_biblio/master_model"
require 'enju_biblio/expire_editable_fragment'
require 'enju_biblio/expire_fragment_cache'
require 'enju_biblio/url_validator'
require 'enju_biblio/import_file'

module EnjuBiblio
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def enju_biblio
      include EnjuBiblio::InstanceMethods
    end
  end

  module InstanceMethods
    private

    def get_work
      @work = Manifestation.find(params[:work_id]) if params[:work_id]
      authorize! :show, @work if @work
    end

    def get_expression
      @expression = Manifestation.find(params[:expression_id]) if params[:expression_id]
      authorize! :show, @expression if @expression
    end

    def get_manifestation
      @manifestation = Manifestation.find(params[:manifestation_id]) if params[:manifestation_id]
      authorize! :show, @manifestation if @manifestation
    end

    def get_item
      @item = Item.find(params[:item_id]) if params[:item_id]
      authorize! :show, @item if @item
    end

    def get_carrier_type
      @carrier_type = CarrierType.find(params[:carrier_type_id]) if params[:carrier_type_id]
    end

    def get_patron
      @patron = Patron.find(params[:patron_id]) if params[:patron_id]
      authorize! :show, @patron if @patron
    end

    def get_series_statement
      @series_statement = SeriesStatement.find(params[:series_statement_id]) if params[:series_statement_id]
    end
  end
end

ActionController::Base.send(:include, EnjuBiblio)
