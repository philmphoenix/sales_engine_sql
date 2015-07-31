require_relative '../loader.rb'
require_relative '../objects/merchant.rb'
require_relative '../modules/util'

class MerchantRepository
  include Util

  attr_accessor :merchants
  attr_reader :engine

  def initialize(args)
    @engine = args.fetch(:engine, nil)
    filename = args.fetch(:filename, './data/fixtures/merchants.csv')
    @loader = Loader.new
    loaded_csvs = @loader.load_csv(filename)
    @merchants = populate_merchants(loaded_csvs)
  end

  def add_merchant(record)
    Merchant.new(record)
  end

  def populate_merchants(loaded_csvs)
    merchants = {}
    loaded_csvs.each do |merchant|
      id = merchant.first
      record = merchant.last
      record[:repository] = self
      merchants[id] = add_merchant(record)
    end
    merchants
  end

end