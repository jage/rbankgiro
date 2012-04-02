require 'helper'

class TestTransaction < Test::Unit::TestCase
  def test_transaction
    transactions = Rbankgiro::Transactions.new(fixture_file_path('one_transaction_09_02_27.txt'))
    transaction = transactions.first

    assert_equal(false, transaction.rounding?)
    assert_equal('86042103700000012', transaction.reference_number)
    assert_equal(1, transaction.amount)
    assert_equal('53090965', transaction.bankgiro_number)
    assert_equal('909897', transaction.service_number)
    assert_equal(Date.parse('Fri Feb 27 00:00:00 2009'), transaction.file_date)
  end
end