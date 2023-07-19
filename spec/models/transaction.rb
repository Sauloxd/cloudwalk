# frozen_string_literal: true

RSpec.describe App::Models::Transaction do
  describe "#save" do
    let(:transaction) { described_class.new(**params) }
    subject { transaction.save }

    context 'on a valid transaction' do 
      let(:params) do
        {
          transaction_id: '1234',
          merchant_id: '1234',
          user_id: 'user_id',
          card_number: '1234',
          transaction_date: '2019-11-21T17:23:32.384281',
          transaction_amount: '1856.42',
          device_id: '123456',
          has_cbk: false,
        }
      end

      it 'should correctly save the model on database' do
        subject 

        expect($REDIS.get('1234')).to eq(params.merge({ reject_reasons: [], recommendation: "approve" }).to_json)
      end
    end

    context 'on an invalid transaction' do 
      let(:params) do
        {
          transaction_id: '1234',
          merchant_id: '1234',
          user_id: 'user_id',
          card_number: '1234',
          transaction_date: '2019-11-21T17:23:32.384281',
          transaction_amount: '1856.42',
          device_id: '123456',
          has_cbk: false,
        }
      end

      before do 
        $REDIS.set("chargebacks:user_id", 1)
        $REDIS.set("last_user_transaction_at:user_id", Time.now)
      end
      let(:reject_reasons) do
        [
          "Invalid due to user user_id transactioning too soon - last transaction was 0 seconds ago.",
          "Invalid due to repeated chargebacks. User user_id already has 1 chargebacks",
        ]
      end

      it 'should not persist on db' do
        subject 

        expect($REDIS.get('1234')).to be_nil
        expect(transaction.reject_reasons).to match(reject_reasons)
        expect(transaction.recommendation).to match(:deny)
      end
    end
  end
end
