# frozen_string_literal: true

RSpec.describe App::Policies::Frauds::Check::RejectOnRepeatedChargebacks do
  describe ".call" do
    subject { described_class.call(transaction) }

    let(:transaction) do
      ::App::Models::Transaction.new(
        transaction_id: '1234',
        merchant_id: '1234',
        user_id: user_id,
        card_number: '1234',
        transaction_date: '2019-11-21T17:23:32.384281',
        transaction_amount: '1856.42',
        device_id: '123456',
        has_cbk: false,
      )
    end
    let(:user_id) { 'another_id' }

    context "when there is a user with a chargeback on db" do
      let(:user_id) { 'fake_id' }

      before do
        $REDIS.set("chargebacks:#{user_id}", 2)
      end

      it 'returns an error' do
        expect(subject).to include(
          "Invalid due to repeated chargebacks. User fake_id already has 2 chargebacks"
        )
      end
    end

    context "when there is no user with a chargeback on db" do
      it 'returns an error' do
        expect(subject).to be_nil
      end
    end
  end
end