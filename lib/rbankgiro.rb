require 'time'

module Rbankgiro
  class CorruptHeader         < StandardError; end
  class InvalidBankgiroNumber < StandardError; end
  class FileFormatError       < StandardError; end
  class TransactionCountError < StandardError; end
  class PartSumError          < StandardError; end

  # A Bankgiro transaction, contains reference_number-number for the transaction
  # amount in SEK and the transaction date
  class Transaction
    attr_reader :amount, :ore, :reference_number, :file_date,
                :bankgiro_number, :lb_flag, :service_number

    OVERPUNCH_TRANSLATION = {
      "-" => "0",
      "J" => "1",
      "K" => "2",
      "L" => "3",
      "M" => "4",
      "N" => "5",
      "O" => "6",
      "P" => "7",
      "Q" => "8",
      "R" => "9"
    }

    def initialize(reference_number, raw_amount, file_date, bankgiro_number, lb_flag = false, service_number = false)
      @raw_amount = raw_amount

      r = raw_amount.match(/^(\d{11})(.)(.)$/)

      if OVERPUNCH_TRANSLATION.include?(r[3])
        raise FileFormatError, "Overpunch but not an LB transaction" unless lb_flag
        amount = "-" + r[1]
        ore    = "-" + r[2] + OVERPUNCH_TRANSLATION[r[3]]
      else
        amount = r[1]
        ore    = r[2] + r[3]
      end

      @amount           = amount.to_i
      @ore              = ore.to_i
      @reference_number = reference_number
      @file_date        = file_date
      @bankgiro_number  = bankgiro_number
      @lb_flag          = lb_flag
      @service_number   = service_number
    end

    # If the amount last two characters aren't 00,
    # there has been some kind of rounding
    def rounding?
      @raw_amount.split('')[-2..-1].join != '00'
    end
  end

  class Transactions < Array
    attr_reader :file_date

    # Parses an reference_number transaction file from Rbankgirocentralen
    # Creates Rbankgiro::Transaction objects for each transaction
    def initialize(file)
      File.read(file).each_line do |row|
        next if row.strip.empty? # Skip empty rows
        parse_row(row)
      end
    end

    def sum
      self.collect {|t| t.amount }.inject {|s,n| s + n }
    end

    def inspect
        sprintf("#<%s:0x%x %s>", self.class.name, __id__,
          "@sum=#{self.sum}, @length=#{self.length}, @file_date=#{self.file_date}")
    end

    def select_with(bankgiro_number)
      self.dup.replace(self.select {|t| t.bankgiro_number == bankgiro_number })
    end

    private

      def parse_row(row)
        columns = row.split(' ').collect {|c| c.strip }.compact
        case columns[0]
        when /^(00)(\d{0,6})/
          # The first row if a File header, should look like:
          # 00<6:service number> <6:date> BANKGIROT
          raise CorruptHeader unless columns[2] == 'BANKGIROT'
          @service_number = $2
          @raw_file_date = columns[1]
          @file_date = Date.parse(@raw_file_date)
        when '10'
        when '20'
          # Specifies the bankgiro number:
          # <8:bankgiro number>
          @bankgiro_number = columns[1]
          raise InvalidBankgiroNumber unless @bankgiro_number
        when '30'
          # Specifies the bankgiro number with the transaction date after:
          # <8:bankgiro number><6:date>
          raise FileFormatError unless columns[1] == @bankgiro_number + @raw_file_date
        when '40'
          # Transaction row:
          # <17:reference number><13:Amount with öre or overpunch>    <2:LB flag if "Leverantörsbetalning">
           if r = columns[1].match(/^(\d+)(.{13})$/)
            reference_number = r[1]
            raw_amount       = r[2]
            lb_flag          = columns[2] == 'LB'
            self << Rbankgiro::Transaction.new(reference_number, raw_amount, @file_date, @bankgiro_number, lb_flag, @service_number)
          else
            raise FileFormatError, "Transaction row"
          end
        when '50'
          # Part payment check
          # <8:Bankgiro or postgiro number><6:file_date><7:number of transactions><part payments in sek><part payments öre>
          if r = columns[1].match(/^(\d+)(\d{6})(\d{7})(\d{13})(\d{2})$/)
            bankgiro_number_control = r[1]
            file_date_control       = r[2]
            number_of_transactions  = r[3].to_i
            payments_sum            = r[4].to_i
          else
            raise FileFormatError, "Part payment row"
          end

          transactions_sum = self.select_with(@bankgiro_number).sum
          unless payments_sum == transactions_sum
            raise PartSumError, "part payment row is #{payments_sum}, transaction sum is #{transactions_sum}"
          end
          raise TransactionCountError unless number_of_transactions == self.select_with(@bankgiro_number).length
        when '90'
          # Total payment check
          # <6:file_date><7:number of transactions><total payments in sek><total payments öre>
          if r = columns[1].match(/^(\d{6})(\d{7})(\d{13})(\d{2})$/)
            file_date_control       = r[1]
            number_of_transactions  = r[2].to_i
            payments_sum            = r[3].to_i
          else
            raise FileFormatError, "Total payment row, syntax error"
          end

          raise PartSumError, "Total payment row" unless payments_sum == self.sum
          raise TransactionCountError unless number_of_transactions == self.length
        else
          # Should be handled by previous cases, if it goes here something is wrong
          raise FileFormatError, "Unknown error"
        end
      end
  end
end
