# frozen_string_literal: true

RSpec.describe App::Actions::Frauds::Check do
  let(:params) do
    {
      transaction_id: '123456',
      merchant_id: '123456',
      user_id: 'user_id',
      card_number: '1231123',
      transaction_date: transaction_date,
      transaction_amount: amount,
      device_id: '123456'
    }
  end
  let(:transaction_date) { '2019-11-21T17:23:32.384281' }
  let(:amount) { '1856.42' }
  
  it "works" do
    response = subject.call(params)
    expect(response.body.first).to eq({
      transaction_id: '123456',
      recommendation: 'approve',
      reasons: []
    }.to_json)
  end

  context 'when user already has a chargeback' do
    before do 
      $REDIS.set("chargebacks:user_id", 1)
    end

    it 'should deny the transaction' do
      response = subject.call(params)
      expect(JSON.parse(response.body.first)).to match({
        "transaction_id" => '123456',
        "recommendation" => 'deny',
        "reasons" => ["Invalid due to repeated chargebacks. User user_id already has 1 chargebacks"]
      })
    end
  end

  context 'when user already performed a transaction too soon' do
    before do 
      $REDIS.set("last_user_transaction_at:user_id", Time.now)
    end

    it 'should deny the transaction' do
      response = subject.call(params)
      expect(JSON.parse(response.body.first)).to match({
        "transaction_id" => '123456',
        "recommendation" => 'deny',
        "reasons" => ["Invalid due to user user_id transactioning too soon - last transaction was 0 seconds ago."]
      })
    end
  end

  context 'when user is performing a transaction with an amount that exceeds the limit on a period' do
    let(:transaction_date) { '2019-11-21T23:00:00' }
    let(:amount) { 2001 }

    it 'should deny the transaction' do
      response = subject.call(params)
      expect(JSON.parse(response.body.first)).to match({
        "transaction_id" => '123456',
        "recommendation" => 'deny',
        "reasons" => ["Invalid due to transaction amount 2001 above threshold 2000 for this time period - from 22:00, to 06:00, timestamp: 2019-11-21T23:00:00"]
      })
    end
  end
end
