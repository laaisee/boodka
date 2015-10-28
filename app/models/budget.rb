# == Schema Information
#
# Table name: budgets
#
#  id            :integer          not null, primary key
#  period_id     :integer          not null
#  category_id   :integer          not null
#  year          :integer          not null
#  month         :integer          not null
#  start_at      :datetime         not null
#  end_at        :datetime         not null
#  amount_cents  :integer          default(0), not null
#  spent_cents   :integer          default(0), not null
#  balance_cents :integer          default(0), not null
#  currency      :string           not null
#  memo          :string           default(""), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Budget < ActiveRecord::Base
  validates :period_id, :category_id, presence: true

  validates :amount_cents,
            :spent_cents, numericality: { greater_than_or_equal_to: 0 }

  validates :balance_cents, numericality: true

  validates :currency, inclusion: { in: Const::CURRENCY_CODES }

  monetize :amount_cents, with_model_currency: :currency
  monetize :spent_cents, with_model_currency: :currency
  monetize :balance_cents, with_model_currency: :currency

  belongs_to :period
  belongs_to :category

  after_initialize :init_boundaries
  after_initialize :init_currency

  def self.refresh!(year, month, category_id)
    params = { year: year, month: month, category_id: category_id }
    find_or_initialize_by(params).refresh!
  end

  def self.new_zero(period, category)
    budget = new(
      period: period,
      category_id: category.id,
      currency: Conf.base_currency,
      year: period.year,
      month: period.month
    )
    budget.balance = budget.prev_balance
    budget
  end

  def refresh!
    self.period = Period.find_or_create!(year, month)
    self.spent = Money.new(expence_cents_sum, Conf.base_currency)
    self.balance = amount - spent + prev_balance
    save!
    next_budget.try(:refresh!)
  end

  def next_budget
    history.where('start_at > ?', start_at).first
  end

  def prev_budget
    history.where('start_at < ?', start_at).last
  end

  def prev_balance
    prev_budget.try(:balance) || zero
  end

  private

  def time_frame
    start_at..end_at
  end

  def zero
    Money.new(0, Conf.base_currency)
  end

  def init_boundaries
    return if persisted?
    today = Date.today
    self.year = today.year unless year
    self.month = today.month unless month
    self.start_at = DateTime.new(year, month)
    self.end_at = start_at + 1.month - 1.second
  end

  def init_currency
    self.currency = Conf.base_currency unless persisted?
  end

  def expense_transactions
    Transaction.expenses.where(category_id: category_id, created_at: time_frame)
  end

  def expence_cents_sum
    expense_transactions.sum(:calculated_amount_cents)
  end

  def history
    self.class.where(category_id: category_id).order(start_at: :asc)
  end
end
