# frozen_string_literal: true

RSpec.describe App::Policies::Frauds::Check::RejectOnRepeatedTransactions do
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

    context "when there is a user with recent transaction" do
      let(:user_id) { 'fake_id' }

      before do
        $REDIS.set("last_user_transaction_at:#{user_id}", Time.now)
      end

      it 'returns an error' do
        expect(subject).to include(
          "Invalid due to user fake_id transactioning too soon - last transaction was 0 seconds ago."
        )
      end
    end

    context "when there is norecent transaction" do
      it 'returns an error' do
        expect(subject).to be_nil
      end
    end
  end
end