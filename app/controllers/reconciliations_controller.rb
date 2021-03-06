class ReconciliationsController < ApplicationController
  before_action :check_availability
  before_action :load_reconciliation, only: [:edit, :update, :destroy]
  before_action :new_reconciliation, only: [:index, :new]

  def create
    @reconciliation = Reconciliation.new(rec_params)
    @reconciliation.save!
  rescue ActiveRecord::RecordInvalid => e
    render :new
  end

  def update
    @reconciliation.assign_attributes(rec_params)
    @reconciliation.save!
  rescue ActiveRecord::RecordInvalid => e
    render :edit
  end

  def destroy
    @reconciliation.destroy
  end

  private

  def permitted_params
    [:account_id, :amount, :created_at]
  end

  def rec_params
    params.require(:reconciliation).permit(permitted_params)
  end

  def load_reconciliation
    @reconciliation = Reconciliation.find(params.require(:id))
  end

  def check_availability
    return if Account.any?
    message = 'There are no accounts, nothing to reconcile.'
    redirect_to(accounts_path, alert: message)
  end

  def account_id
    params[:account_id]
  end

  def new_reconciliation_params
    return {} unless account_id
    account = Account.find(account_id)
    {
      account: account,
      amount: Calc.total(account: account)
    }
  end

  def new_reconciliation
    @reconciliation = Reconciliation.new(new_reconciliation_params)
  end

  def ops_path
    year = @reconciliation.created_at.year
    month = @reconciliation.created_at.month
    operations_path(year, month)
  end
end
