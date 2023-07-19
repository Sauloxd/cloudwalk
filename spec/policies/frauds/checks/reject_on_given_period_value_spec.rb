# frozen_string_literal: true

RSpec.describe App::Policies::Frauds::Check::RejectOnGivenPeriodValue do
  describe ".call" do
    subject do
      ->(amount, date) do
        transaction.transaction_amount = amount
        transaction.transaction_date = date 
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

    context '22:00 ~ 06:00' do
      it 'allows if bellow max_amount of 2000' do
        expect(subject.call(1000, '23:00:00')).to be_nil
      end
      it 'denies if above max_amount of 2000' do
        expect(subject.call(2001, '23:00:00')).to include ("Invalid due to transaction amount 2001 above threshold 2000 for this time period - from 22:00, to 06:00")
      end
    end

    context '06:00 ~ 09:00' do
      it 'allows if bellow max_amount of 10000' do
        expect(subject.call(5000, '07:00:00')).to be_nil
      end
      it 'denies if above max_amount of 10000' do
        expect(subject.call(100001, '07:00:00')).to include ("Invalid due to transaction amount 100001 above threshold 10000 for this time period - from 06:00, to 09:00")
      end
    end

    context '09:00 ~ 18:00' do
      it 'allows if bellow max_amount of 50000' do
        expect(subject.call(49000, '15:00:00')).to be_nil
      end
      it 'denies if above max_amount of 50000' do
        expect(subject.call(100001, '15:00:00')).to include ("Invalid due to transaction amount 100001 above threshold 50000 for this time period - from 09:00, to 18:00, timestamp: 15:00:00")
      end
    end

    context '18:00 ~ 22:00' do
      it 'allows if bellow max_amount of 10000' do
        expect(subject.call(9000, '19:00:00')).to be_nil
      end
      it 'denies if above max_amount of 10000' do
        expect(subject.call(10001, '19:00:00')).to include ("Invalid due to transaction amount 10001 above threshold 10000 for this time period - from 18:00, to 22:00, timestamp: 19:00:00")
      end
    end
  end
end