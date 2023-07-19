# frozen_string_literal: true

class SetupRedisWithCSVData
  def self.call(redis)
    # Since I know I want to search for transactions for the same user/amount/merchant/device/credit_card,
    # Lets compose a key with this attributes

    # transaction_id,merchant_id,user_id,card_number,transaction_date,transaction_amount,device_id,has_cbk
    redis.flushdb
    content = File.read(File.join(File.dirname(__FILE__), '../data_sample.csv'))
    result = content.split("\n").slice(1..).map do |line|
    
      transaction_id,
      merchant_id,
      user_id,
      card_number,
      transaction_date,
      transaction_amount,
      device_id,
      has_cbk  = line.split(",")

      # Save if user had a chargeback before
      if has_cbk == 'TRUE'
        key = "chargebacks:#{user_id}"
        redis.incr(key)
      end

      {
        transaction_id: transaction_id,
        merchant_id: merchant_id,
        user_id: user_id,
        card_number: card_number,
        transaction_date: transaction_date,
        transaction_amount: transaction_amount,
        device_id: device_id,
        has_cbk: has_cbk
      }
    end
  end
end