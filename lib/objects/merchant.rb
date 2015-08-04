require 'set'
require_relative '../modules/record_like'
require_relative '../modules/relationship'

class Merchant
  include RecordLike
  include Relationships

  attr_accessor :name, :created_at , :updated_at
  attr_reader :id, :repository

  def initialize(record)
    @id          = record[:id]
    @name        = record[:name]
    @created_at  = record[:created_at]
    @updated_at  = record[:updated_at]
    @repository  = record.fetch(:repository, nil)
  end

  def items
    repository.get(:items, id, :merchant_id)
  end

  def invoices
    repository.get(__callee__, id, :merchant_id)
  end

  def invoices_for(date)
    if date == "all"
      invoices
    else
      invoices.select do |invoice|
        invoice.created_at.to_date == date.to_date
      end
    end
  end

  #clean
  def paid_invoices
    repository.paid_invoices(self)
  end

  def unpaid_invoices
    repository.unpaid_invoices(self)
    # invoices.reject(&:paid?)
  end

  #clean
  def paid_invoices_for(date)
    if date == "all"
      paid_invoices
    else
      paid_invoices.select do |invoice|
        invoice.created_at.to_date == date.to_date
      end
    end
  end

  def invoice_items_for(date)
    invoice_items(invoices_for(date))
  end

  def invoice_items(invoices)
    invoices.map do |invoice|
      invoice.invoice_items
    end.flatten
  end

  def paid_invoice_items_for(date = "all")
    invoice_items(paid_invoices_for(date))
  end

  def revenue(date = "all")
    paid_invoices_for(date).reduce(0) do |acc, invoice|
      acc + invoice.total_billed
    end
  end

  #clean
  def favorite_customer
    #assumes at most one successful transaction per invoice
    customers = paid_invoices.group_by{|invoice| invoice.customer}
    customers.max_by do |id, invoices|
      invoices.length
    end.first
  end

  def customers_with_pending_invoices
    customers = unpaid_invoices.map{|invoice| invoice.customer}.uniq
  end
end