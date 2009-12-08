require 'helper'

class TestTransactions < Test::Unit::TestCase  
  def test_one_transaction
    transactions = Rbankgiro::Transactions.new(fixture_file_path('one_transaction_09_02_27.txt'))
    
    assert_equal(1, transactions.sum)
    assert_equal(1, transactions.length)
    assert_equal(Time.parse('Fri Feb 27 00:00:00 +0100 2009'), transactions.file_date)
  end
  
  def test_multiple_transactions
    transactions = Rbankgiro::Transactions.new(fixture_file_path('multiple_transactions_06_06_20.txt'))
    
    # Test SEK
    assert_equal(47093, transactions.sum)
    assert_equal(38, transactions.length)
    assert_equal(Time.parse('Tue Jun 20 00:00:00 +0200 2006'), transactions.file_date)
    
    # Test LB flag
    assert_equal(false, transactions[28].lb_flag)
    assert transactions[27].lb_flag
    assert transactions[30].lb_flag
    assert transactions[31].lb_flag
    assert transactions[36].lb_flag
    assert transactions[37].lb_flag
    
    # Test Öre
    assert_equal(95, transactions[27].ore)
    assert_equal(-95, transactions[36].ore)
  end
  
  def test_multiple_transaction_with_postgiro
    transactions = Rbankgiro::Transactions.new(fixture_file_path('multiple_transactions_with_plusgiro_06_06_20.txt'))
    
    assert_equal(55166, transactions.sum)
    assert_equal(37, transactions.length)
    assert_equal(Time.parse('Tue Jun 20 00:00:00 +0200 2006'), transactions.file_date)
    
    for i in 0..1
      assert_equal('99123465', transactions[i].bankgiro_number)
    end
    
    for i in 2..36
      assert_equal('9912346', transactions[i].bankgiro_number)
    end
  end
  
  def test_overpunch_without_lb_flag
    assert_raise(Rbankgiro::FileFormatError) do
      Rbankgiro::Transactions.new(fixture_file_path('overpunch_transaction_with_missing_lb_flag_06_06_20.txt'))
    end
  end
  
  def test_missing_transaction
    assert_raise(Rbankgiro::PartSumError) do
      Rbankgiro::Transactions.new(fixture_file_path('missing_transaction_09_02_27.txt'))
    end
  end
  
  def test_corrupt_header
    assert_raise(Rbankgiro::CorruptHeader) do
      Rbankgiro::Transactions.new(fixture_file_path('corrupt_header_09_02_27.txt'))    
    end
  end
  
  def test_invalid_bankgiro_number
    assert_raise(Rbankgiro::InvalidBankgiroNumber) do
      Rbankgiro::Transactions.new(fixture_file_path('invalid_bankgiro_number_09_02_27.txt'))
    end
  end
  
  def test_file_format_error
    assert_raise(Rbankgiro::FileFormatError) do
      Rbankgiro::Transactions.new(fixture_file_path('file_format_error_09_02_27.txt'))    
    end
  end
  
  def test_transaction_count_error
    assert_raise(Rbankgiro::TransactionCountError) do
      Rbankgiro::Transactions.new(fixture_file_path('one_too_many_transactions_09_02_27.txt'))    
    end
  end
end