# == Schema Information
#
# Table name: rates
#
#  id         :integer          not null, primary key
#  ask        :float            not null
#  bid        :float            not null
#  rate       :float            not null
#  from       :string           not null
#  to         :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class RateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
