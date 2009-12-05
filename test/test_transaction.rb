require 'helper'

class TestTransaction < Test::Unit::TestCase  
  def test_transaction
    transactions = Rbankgiro::Transactions.new(fixture_file_path('one_transaction_09_02_27.txt'), '53090965')
    transaction = transactions.first
        
    assert_equal(false, transaction.rounding?)
    assert_equal('86042103700000012', transaction.ocr)
    assert_equal(1, transaction.amount)
    assert_equal(Time.parse('Fri Feb 27 00:00:00 +0100 2009'), transaction.file_date)
  end
end