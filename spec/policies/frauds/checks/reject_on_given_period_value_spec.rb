# frozen_string_literal: true

RSpec.describe App::Policies::Frauds::Check::RejectOnGivenPeriodValue do
  describe ".call" do
    subject do
      ->(amount) do
        transaction.transaction_amount = amount
        transaction.transaction_date = hour 
        described_class.call(transaction)
      end
    end

    let(:transaction) do
      ::App::Models::Transaction.new(
        transaction_id: '1234',
        merchant_id: '1234',
        user_id: 'user_id',
        card_number: '1234',
        transaction_date: '2019-11-21T17:23:32.384281',
        transaction_amount: '1856.42',
        device_id: '123456',
        has_cbk: false,
      )
    end

    context '22:00 ~ 03:00' do
      let(:hour) { '23:00:00' }
      
      it 'allows if bellow max_amount of 570.43' do
        expect(subject.call(300)).to be_nil
      end
      it 'denies if above max_amount of 570.43' do
        expect(subject.call(2001)).to include("Invalid due to transaction amount 2001 above threshold 570.43 for this time period - from 22:00, to 03:00")
      end
    end

    context '03:00 ~ 19:00' do
      let(:hour) { '11:00:00' }

      it 'allows every amount' do
        expect(subject.call(5000)).to be_nil
        expect(subject.call(0)).to be_nil
        expect(subject.call(100000)).to be_nil
      end
    end

    context '19:00 ~ 22:00' do
      let(:hour) { '21:00:00' }

      it 'allows if bellow max_amount of 1366.69' do
        expect(subject.call(1000)).to be_nil
      end
      it 'denies if above max_amount of 1366.69' do
        expect(subject.call(1370)).to include("Invalid due to transaction amount 1370 above threshold 1366.69 for this time period - from 19:00, to 22:00")
      end
    end
  end
end