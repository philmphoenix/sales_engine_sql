require 'pry'
require_relative '../loader.rb'
require_relative '../objects/transaction.rb'
require_relative '../modules/util'

class TransactionRepository
  include Util

  attr_accessor :transactions
  attr_reader :engine, :records

  def initialize(args)
    @engine = args.fetch(:engine, nil)
    filename = args.fetch(:filename, 'transactions.csv')
    path = args.fetch(:path, './data/fixtures/') + filename
    @loader = Loader.new
    loaded_csvs = @loader.load_csv(path)
    @transactions = populate_transactions(loaded_csvs)
    @records = @transactions
  end

  def create_record(record)
    Transaction.new(record)
  end

  def populate_transactions(loaded_csvs)
    transactions = {}
    loaded_csvs.each do |transaction|
      id = transaction.first
      record = transaction.last
      record[:repository] = self
      transactions[id] = create_record(record)
    end
    transactions
  end

  def inspect
    "#<#{self.class} #{@transactions.size} rows>"
  end

  def count
    all.count{|trans| trans.successful?}
  end

  def charge(args, invoice)
    record = args
    record[:invoice_id] = invoice
    record[:id] = next_id
    record[:result] = args[:result]
    record[:created_at] = timestamp
    record[:updated_at] = timestamp
    transactions[record[:id]] = create_record(record)
    @records = @transactions
  end
end