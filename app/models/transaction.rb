# == Schema Information
#
# Table name: transactions
#
#  id                         :integer          not null, primary key
#  account_id                 :integer          not null
#  amount_cents               :integer          default(0), not null
#  amount_currency            :string           default("USD"), not null
#  calculated_amount_cents    :integer          default(0), not null
#  calculated_amount_currency :string           default("USD"), not null
#  rate                       :float            default(1.0), not null
#  category_id                :integer
#  transfer_id                :integer
#  description                :string           default(""), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class Transaction < ActiveRecord::Base
  monetize :amount_cents,
           with_model_currency: :amount_cents_currency

  monetize :calculated_amount_cents,
           with_model_currency: :calculated_amount_currency

  validates :abs_amount, numericality: {
    greater_than: 0,
    message: 'Amount must have a non-zero value'
  }

  validates :amount_currency,
            :calculated_amount_currency,
            inclusion: { in: Const::CURRENCY_CODES }

  validates :account_id, presence: true

  belongs_to :category
  belongs_to :account
  belongs_to :transfer

  scope :with_account, -> { includes(:account) }
  scope :history, -> { with_account.order(created_at: :desc) }
  scope :recent_history, -> { history.limit(Const::RECENT_HISTORY_LENGTH) }

  before_create :refresh_rate_and_convert_amount
  before_update :convert_amount

  delegate :currency, to: :account, prefix: :account

  def abs_amount
    amount.abs
  end

  def abs_calculated_amount
    calculated_amount.abs
  end

  def transfer?
    transfer_id.present?
  end

  def inflow?
    amount_cents > 0
  end

  def outflow?
    amount_cents < 0
  end

  def uncategorized?
    category.nil?
  end

  private

  def refresh_rate_and_convert_amount
    self.calculated_amount = amount.exchange_to(account_currency)
    self.rate = Money.default_bank.get_rate(amount_currency, account_currency)
  end

  def convert_amount
    self.calculated_amount_cents = Integer(amount_cents * rate)
  end
end
