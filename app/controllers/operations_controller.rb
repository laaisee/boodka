class OperationsController < ApplicationController
  include Periodical

  OPS = %w(transaction reconciliation transfer)

  before_action :validate_params, :load_history

  private

  def load_history
    @ops = OperationsFacade.new(
      filtered?,
      operation_types,
      category,
      operations
    )
  end

  def filtered?
    category.present? || (operation_types != OPS)
  end

  def operations
    order = -> (a, b) { b.created_at <=> a.created_at }
    operation_types.map { |model| scope(model) }.flatten.sort(&order)
  end

  def operation_types
    operation.present? ? [operation] : OPS
  end

  def scope(model)
    model.classify.constantize.history.where(scope_criteria(model))
  end

  def scope_criteria(model)
    { created_at: time_frame, category: category }.delete_if { |_, v| v.nil? }
  end

  def time_frame
    start_date.beginning_of_month..start_date.end_of_month
  end

  def category
    return unless category_id
    @category ||= Category.find(category_id)
  end

  def category_id
    params[:category_id]
  end

  def operation
    params[:operation]
  end

  def validate_params
    fail 'Illegal operation type' if operation && !OPS.include?(operation)
  end
end
