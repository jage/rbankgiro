require 'helper'

class TestTransactions < Test::Unit::TestCase  
  def test_one_transaction
    transactions = Rbankgiro::Transactions.new(fixture_file_path('one_transaction_09_02_27.txt'), '53090965')
    
    assert_equal(1, transactions.sum)
    assert_equal(1, transactions.length)
    assert_equal(Time.parse('Fri Feb 27 00:00:00 +0100 2009'), transactions.file_date)
  end
  
  def test_missing_transaction
    assert_raise(Rbankgiro::PartSumError) do
      Rbankgiro::Transactions.new(fixture_file_path('missing_transaction_09_02_27.txt'), '53090965')    
    end
  end
  
  def test_corrupt_header
    assert_raise(Rbankgiro::CorruptHeader) do
      Rbankgiro::Transactions.new(fixture_file_path('corrupt_header_09_02_27.txt'), '53090965')    
    end
  end
  
  def test_invalid_bankgiro_number
    assert_raise(Rbankgiro::InvalidBankgiroNumber) do
      Rbankgiro::Transactions.new(fixture_file_path('one_transaction_09_02_27.txt'), '53090966')
    end
  end
  
  def test_file_format_error
    assert_raise(Rbankgiro::FileFormatError) do
      Rbankgiro::Transactions.new(fixture_file_path('file_format_error_09_02_27.txt'), '53090965')    
    end
  end
  
  def test_transaction_count_error
    assert_raise(Rbankgiro::TransactionCountError) do
      Rbankgiro::Transactions.new(fixture_file_path('one_too_many_transactions_09_02_27.txt'), '53090965')    
    end
  end
  
end