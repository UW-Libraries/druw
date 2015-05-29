# app/controller/collections_controller.rb

class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior

  self.presenter_class = MyCollectionsPresenter
end
