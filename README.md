# rbankgiro - parse Bankgiro transaction files [![Tested with Travis-CI](https://secure.travis-ci.org/jage/rbankgiro.png)](http://travis-ci.org/#!/jage/rbankgiro)

Read more about bankgiro at: http://www.bgc.se/

## Usage

Bankgiro transactions are stored in plain text files, these are generated by [BGC][1]. Rbankgiro reads and parses these files.

`Rbankgiro::Transactions` is an extended `Array` which stores `Rbankgiro::Transaction` objects, each object being a Bankgiro transaction. 

Read a transaction file:

	require 'rbankgiro'

	transactions = Rbankgiro::Transactions.new('transactions_06_06_20.txt')
	# => #<Rbankgiro::Transactions:0x3fe8ac5e7110 @sum=47093, @length=38, @file_date=2006-06-20 00:00:00 +0200>

* `Rbankgiro::Transactions#sum` total sum of all transactions

`Rbankgiro::Transaction` reflects all information stored in a Bankgiro transaction file.

	transaction = transactions.first
	# => #<Rbankgiro::Transaction:0x007fd158bcbdb8 @raw_amount="0000000147700", @amount=1477, @ore=0, @reference_number="3940715", @file_date=2006-06-20 00:00:00 +0200, @bankgiro_number="9912346", @lb_flag=false, @service_number="">

* `Rbankgiro::Transaction#raw_amount` is a copy of BGCs amount string
* `Rbankgiro::Transaction#amount` is the transferred amount of whole SEK as an Integer
* `Rbankgiro::Transaction#ore` is the amount of öre  which was transferred
* `Rbankgiro::Transaction#reference_number` payment reference number
* `Rbankgiro::Transaction#file_date` date of the generated bankgiro transaction file
* `Rbankgiro::Transaction#bankgiro_number` to which bankgiro number the payments are transferred
* `Rbankgiro::Transaction#lb_flag` indicates "Leverantörsbetalning"
* `Rbankgiro::Transaction#service_number` is the service number
* `Rbankgiro::Transaction#rounded?` is true if there was rounding in the transactions

For more specifics, read the Bankgiro manual at [BGC][1].

[1]: http://www.bgc.se/	"BGC"