# app/controller/collections_controller.rb

class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior
  before_filter :remove_selection_flash, only: :new

  def presenter_class
    MyCollectionPresenter
  end

  def form_class
    MyCollectionEditForm
  end

  def collection_params
    params.require(:collection).permit(:title, :description, :members, part_of: [],
                                       contributor: [], creator: [], publisher: [], date_created: [], subject: [],
                                       language: [], rights: [], resource_type: [], identifier: [], based_near: [],
                                       tag: [], related_url: [], alternative: [], license: [], accrual_policy: [],
                                       accrual_periodicity: [])
  end
end
