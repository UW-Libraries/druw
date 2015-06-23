class MyCollectionEditForm < MyCollectionPresenter
  def terms
    super - [:size, :total_items]
  end

  # Test to see if the given field is required
  # @param [Symbol] key a field
  # @return [Boolean] is it required or not
  def required?(key)
    model_class.validators_on(key).any?{|v| v.kind_of? ActiveModel::Validations::PresenceValidator}
  end
end
