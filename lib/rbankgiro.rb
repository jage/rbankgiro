require 'time'

module Rbankgiro
  class CorruptHeader         < StandardError; end
  class InvalidBankgiroNumber < StandardError; end
  class FileFormatError       < StandardError; end
  class TransactionCountError < StandardError; end
  class PartSumError          < StandardError; end
    
  # A Rbankgiro transaction, contains OCR-number for the transaction
  # amount in SEK and the transaction date
  class Transaction
    attr_reader :amount, :ocr, :file_date
    
    def initialize(ocr, raw_amount, file_date)
      @raw_amount = raw_amount
      @ocr        = ocr
      @amount     = raw_amount.split('')[0..-3].join.to_i
      @file_date  = file_date
    end 
    
    # If the amount last two characters aren't 00, 
    # there has been some kind of rounding
    def rounding?
      @raw_amount.split('')[-2..-1].join != '00'
    end
  end

  class Transactions < Array
    attr_reader :file_date
    
    # Parses an OCR transaction file from Rbankgirocentralen
    # Creates Rbankgiro::Transaction objects for each transaction
    def initialize(file, bankgiro_number)
      @bankgiro_number = bankgiro_number.to_s
      
      ocr_transaction_input = File.open(file, 'r') {|f| f.read }
      ocr_transaction_input.each_line do |row|
        next if row.strip.empty? # Skip empty rows
        parse_row(row)
      end
    end
    
    def sum
      self.collect {|t| t.amount }.reduce(:+)
    end
    
    def inspect
        sprintf("#<%s:0x%x %s>", self.class.name, __id__, 
          "@sum=#{self.sum}, @length=#{self.length}, @file_date=#{self.file_date}")
    end
    
    private
    
      def parse_row(row)
        columns = row.scan(/\w+/).collect {|c| c.strip }
        case columns.first
        when '00909897' 
          # The first row if a File header, should look like:
          # 00909897 <6:date> BANKGIROT
          raise CorruptHeader unless columns[2] == 'BANKGIROT'
          @raw_file_date = columns[1]
          @file_date = Time.parse(@raw_file_date)
        when '10'
        when '20'
          # Specifies the bankgiro number:
          # <8:bankgiro number>
          raise InvalidBankgiroNumber unless columns[1] == @bankgiro_number
        when '30' 
          # Specifies the bankgiro number with the transaction date after:
          # <8:bankgiro number><6:date>
          raise FileFormatError unless columns[1] == @bankgiro_number + @raw_file_date
        when '40' 
          # Transaction row:
          # <17:OCR-number><13:Amount with ören)
           if r = columns[1].match(/^(\d{17})(\d{13})$/)
            ocr        = r[1]
            raw_amount = r[2]
            self << Rbankgiro::Transaction.new(ocr, raw_amount, @file_date)
          else
            raise FileFormatError
          end
        when '50'
          # Part payment check
          # <8:Rbankgiro number><6:file_date><7:number of transactions><part payments with öre>
          if r = columns[1].match(/^(\d{8})(\d{6})(\d{7})(\d{15})$/)
            bankgiro_number_control = r[1]
            file_date_control       = r[2]
            number_of_transactions  = r[3]
            payments_raw_sum        = r[4]
            payments_sum = payments_raw_sum.split('')[0..-3].join.to_i # Remove the Öre
            
          else
            raise FileFormatError
          end
            
          raise PartSumError          unless payments_sum == self.collect {|t| t.amount }.reduce(:+) 
          raise TransactionCountError unless number_of_transactions.to_i == self.length
        when '90'
          # Total payment check
          # <6:file_date><7:number of transactions><part payments with öre>
          if r = columns[1].match(/^(\d{6})(\d{7})(\d{15})$/)
            file_date_control       = r[1]
            number_of_transactions  = r[2]
            payments_raw_sum        = r[3]
            payments_sum = payments_raw_sum.split('')[0..-3].join.to_i # Remove the Öre
          else
            raise FileFormatError
          end
            
          raise PartSumError          unless payments_sum == self.collect {|t| t.amount }.reduce(:+)
          raise TransactionCountError unless number_of_transactions.to_i == self.length
        else
          # Should be handled by previous cases, if it goes here something is wrong
          raise FileFormatError
        end
      end
  end
end
