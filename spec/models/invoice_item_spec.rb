require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe "validations" do
    it { should validate_presence_of :invoice_id }
    it { should validate_presence_of :item_id }
    it { should validate_presence_of :quantity }
    it { should validate_presence_of :unit_price }
    it { should validate_presence_of :status }
  end
  describe "relationships" do
    it { should belong_to :invoice }
    it { should belong_to :item }
    it { should have_many(:bulk_discounts).through(:item) }
  end

  describe "class methods" do
    before(:each) do
      @m1 = Merchant.create!(name: 'Merchant 1')
      
      @c1 = Customer.create!(first_name: 'Bilbo', last_name: 'Baggins')
      @c2 = Customer.create!(first_name: 'Frodo', last_name: 'Baggins')
      @c3 = Customer.create!(first_name: 'Samwise', last_name: 'Gamgee')
      @c4 = Customer.create!(first_name: 'Aragorn', last_name: 'Elessar')
      @c5 = Customer.create!(first_name: 'Arwen', last_name: 'Undomiel')
      @c6 = Customer.create!(first_name: 'Legolas', last_name: 'Greenleaf')
      
      @item_1 = Item.create!(name: 'Shampoo', description: 'This washes your hair', unit_price: 10, merchant_id: @m1.id)
      @item_2 = Item.create!(name: 'Conditioner', description: 'This makes your hair shiny', unit_price: 8, merchant_id: @m1.id)
      @item_3 = Item.create!(name: 'Brush', description: 'This takes out tangles', unit_price: 5, merchant_id: @m1.id)
      
      @i1 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i2 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i3 = Invoice.create!(customer_id: @c2.id, status: 2)
      @i4 = Invoice.create!(customer_id: @c3.id, status: 2)
      @i5 = Invoice.create!(customer_id: @c4.id, status: 2)

      @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
      @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 15, unit_price: 8, status: 0)
      @ii_3 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_3.id, quantity: 5, unit_price: 5, status: 2)
      @ii_4 = InvoiceItem.create!(invoice_id: @i3.id, item_id: @item_3.id, quantity: 5, unit_price: 5, status: 1)
      @ii_5 = InvoiceItem.create!(invoice_id: @i3.id, item_id: @item_3.id, quantity: 10, unit_price: 5, status: 1)
      
      @discount1 = BulkDiscount.create(merchant_id: @m1.id, percentage_discount: 0.1, quantity_threshold: 1, promo_name: "Welcome" )
      @discount2 = BulkDiscount.create(merchant_id: @m1.id, percentage_discount: 0.2, quantity_threshold: 5, promo_name: "Promo" )
      @discount3 = BulkDiscount.create(merchant_id: @m1.id, percentage_discount: 0.3, quantity_threshold: 10, promo_name: "Best" )
      @discount4 = BulkDiscount.create(merchant_id: @m1.id, percentage_discount: 0.10, quantity_threshold: 15, promo_name: "Best" )
    end

    it 'incomplete_invoices' do
      expect(InvoiceItem.incomplete_invoices).to eq([@i1, @i3])
    end

    context "applied_discount" do
      it "finds a bulk discount that applies to an ivoice item" do
        expect(@ii_5.applied_discount).to eq(@discount3)
        expect(@ii_1.applied_discount).to_not eq(@discount3)
      end

      it "applies the higher discount based on quantity threshold" do
        expect(@ii_2.applied_discount).to eq(@discount3)
        expect(@ii_2.applied_discount).to_not eq(@discount4)
      end
    end
  end
end
