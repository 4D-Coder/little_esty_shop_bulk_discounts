require 'rails_helper'

RSpec.describe 'merchant bulk discounts edit' do
  describe 'As a merchant' do
    context "When I visit the bulk discounts edit page" do
      before :each do
        @merchant1 = Merchant.create!(name: 'Hair Care')
        @merchant2 = Merchant.create!(name: 'Trippy Emporium')

        @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        @customer_2 = Customer.create!(first_name: 'Cecilia', last_name: 'Jones')
        @customer_3 = Customer.create!(first_name: 'Mariah', last_name: 'Carrey')
        @customer_4 = Customer.create!(first_name: 'Leigh Ann', last_name: 'Bron')
        @customer_5 = Customer.create!(first_name: 'Sylvester', last_name: 'Nader')
        @customer_6 = Customer.create!(first_name: 'Herber', last_name: 'Kuhn')

        @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2)
        @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2)
        @invoice_3 = Invoice.create!(customer_id: @customer_2.id, status: 2)
        @invoice_4 = Invoice.create!(customer_id: @customer_3.id, status: 2)
        @invoice_5 = Invoice.create!(customer_id: @customer_4.id, status: 2)
        @invoice_6 = Invoice.create!(customer_id: @customer_5.id, status: 2)
        @invoice_7 = Invoice.create!(customer_id: @customer_6.id, status: 1)

        @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id)
        @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
        @item_3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: @merchant1.id)
        @item_4 = Item.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1, merchant_id: @merchant1.id)

        @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
        @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
        @ii_3 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
        @ii_4 = InvoiceItem.create!(invoice_id: @invoice_3.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
        @ii_5 = InvoiceItem.create!(invoice_id: @invoice_4.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
        @ii_6 = InvoiceItem.create!(invoice_id: @invoice_5.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
        @ii_7 = InvoiceItem.create!(invoice_id: @invoice_6.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)

        @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)
        @transaction2 = Transaction.create!(credit_card_number: 230948, result: 1, invoice_id: @invoice_3.id)
        @transaction3 = Transaction.create!(credit_card_number: 234092, result: 1, invoice_id: @invoice_4.id)
        @transaction4 = Transaction.create!(credit_card_number: 230429, result: 1, invoice_id: @invoice_5.id)
        @transaction5 = Transaction.create!(credit_card_number: 102938, result: 1, invoice_id: @invoice_6.id)
        @transaction6 = Transaction.create!(credit_card_number: 879799, result: 1, invoice_id: @invoice_7.id)
        @transaction7 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_2.id)

        @bulk_discount1 = @merchant1.bulk_discounts.create!(percentage_discount: 0.2, quantity_threshold: 2, promo_name: "First Time Buyer")
        @bulk_discount2 = @merchant1.bulk_discounts.create!(percentage_discount: 0.3, quantity_threshold: 5, promo_name: "Loyalty Reward")
        @bulk_discount3 = @merchant2.bulk_discounts.create!(percentage_discount: 0.42, quantity_threshold: 10, promo_name: "420 Special")
        @bulk_discount4 = @merchant2.bulk_discounts.create!(percentage_discount: 0.7, quantity_threshold: 100, promo_name: "Happy 710")
        
        visit edit_merchant_bulk_discount_path(@merchant2.id, @bulk_discount4.id)
      end

      it "I see that theres a form to edit the bulk discount, and its current attributes are pre-poluated in the form" do

        within('section#edit_bulk_discount_form') do
          expect(page).to have_field("Promo Name", with: @bulk_discount4.promo_name)
          expect(page).to have_field("Discount Percentage", with: @bulk_discount4.percentage_discount)
          expect(page).to have_field("Quantity Threshold", with: @bulk_discount4.quantity_threshold)
          expect(page).to have_button("Submit")
        end
      end

      it "can fill in the form with invalid data, and is redirected back to the bulk discount edit page" do
      
        within('section#edit_bulk_discount_form') do
          fill_in "Promo Name:", with: "Happy 710"
          fill_in "Discount Percentage:", with: -7
          fill_in "Quantity Threshold:", with: 1
          click_button "Submit"
        end

        expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant2.id, @bulk_discount4.id))
        expect(page).to have_content("Please check your entries and try again.")
      end

      it "I can change any/all fields with valid data, im redirected back to the bulk discount show, and I see that the discount's attributes have been updated" do
        within('section#edit_bulk_discount_form') do
          fill_in "Promo Name:", with: "Happy 710"
          fill_in "Discount Percentage:", with: 7
          fill_in "Quantity Threshold:", with: 3
          click_button "Submit"
        end
        
        expect(current_path).to eq(merchant_bulk_discount_path(@merchant2.id, @bulk_discount4.id))
        expect(page).to have_content("Your input has been saved.")

        within("section#merchant_bulk_discount-#{@bulk_discount4.id}") do
          expect(page).to have_content("Promo: Happy 710")
          expect(page).to have_content("Discount: 700.0%")
          expect(page).to have_content("Quantity Threshold: 3")
        end
        
        visit edit_merchant_bulk_discount_path(@merchant2.id, @bulk_discount4.id)
        
        within('section#edit_bulk_discount_form') do
          fill_in "Promo Name:", with: "Happy 710!"
          fill_in "Discount Percentage:", with: 0.07
          fill_in "Quantity Threshold:", with: 2
          click_button "Submit"
        end
        
        expect(current_path).to eq(merchant_bulk_discount_path(@merchant2.id, @bulk_discount4.id))
        expect(page).to have_content("Your input has been saved.")

        within("section#merchant_bulk_discount-#{@bulk_discount4.id}") do
          expect(page).to have_content("Promo: Happy 710!")
          expect(page).to have_content("Discount: 7.0%")
          expect(page).to have_content("Quantity Threshold: 2")
        end
      end
    end
  end
end