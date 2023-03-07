require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end

  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many :transactions}
    it { should have_many :invoice_items}
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
  end

  describe "instance methods" do
    before :each do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @merchant2 = Merchant.create!(name: 'Jewelry')

      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 15, merchant_id: @merchant1.id)
      @item_5 = Item.create!(name: "Bracelet", description: "Wrist bling", unit_price: 200, merchant_id: @merchant2.id)
      @item_6 = Item.create!(name: "Necklace", description: "Neck bling", unit_price: 300, merchant_id: @merchant2.id)
      
      
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 5, unit_price: 10, status: 2)
      @ii_13 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 10, unit_price: 15, status: 2)
      @ii_6 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_5.id, quantity: 5, unit_price: 1, status: 1)
      @ii_7 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_6.id, quantity: 5, unit_price: 3, status: 1)

      @discount1 = BulkDiscount.create(merchant_id: @merchant1.id, percentage_discount: 0.1, quantity_threshold: 10, promo_name: "Welcome" )
      @discount2 = BulkDiscount.create(merchant_id: @merchant1.id, percentage_discount: 0.05, quantity_threshold: 15, promo_name: "Thank You" )
      @discount3 = BulkDiscount.create(merchant_id: @merchant2.id, percentage_discount: 0.15, quantity_threshold: 5, promo_name: "Bonus" )
      @discount4 = BulkDiscount.create(merchant_id: @merchant2.id, percentage_discount: 0.50, quantity_threshold: 10, promo_name: "GO" )
    end

    it "#total_revenue" do
      expect(@invoice_1.total_revenue).to eq(200)
    end

    it "#discounted_total" do
      expect(@invoice_1.discounted_total).to eq(30)
    end

    it "discounted_revenue_for()" do
      expect(@invoice_1.discounted_revenue_for(@merchant2)).to_eq(3)
      #merchant 1: 
        # Item 1(ii_1) & Item 8(ii_13)
          # ii_1: 10up * 5q (<- 0%) = 50
          # ii_13: 15up * 10q (<- 10%) = 150

      #merchant 2: 
        # Item 5(ii_6) & Item 6(ii_7)
          # ii_6: 1up * 5q (<- 15%) = 5 * .15 = 4.25 - .75
          # ii_7: 3up * 5q (<- 15%) = 15 * .15 = 12.75 - 2.25
          # disc. rev = 3
    end
  end
end
