# CSV analysis

## Analyze the data provided and present your conclusions (consider that all transactions are made using a mobile device).

After analysing the CSV, here are some of the insights:

### After 19h, frauds spike to more than 10% of the transactions in this hour window.
``` ruby 
# At what time the happens the most?
r = dataset
  .map { |l| l.merge(date: Time.parse(l[:transaction_date])) }
  .group_by { |l| l[:date].hour }
  .map do |hour, v|
    frauds = v.select{|l| l[:has_cbk] == "TRUE"}
    legits =  v.select{|l| l[:has_cbk] == "FALSE" }
    ratio = (frauds.count * 100/(legits.count + frauds.count).to_f).round(2)
    average_legit = (legits.sum { |l| l[:transaction_amount].to_f } / legits.count.to_f).round(2)
    average_fraud = (frauds.sum { |l| l[:transaction_amount].to_f } / frauds.count.to_f).round(2)

    [hour, { 
      fraud: frauds.count, 
      legit: legits.count,
      ratio: ratio,
      average_legit: average_legit,
      average_fraud: average_fraud,
    }]
  end
  .sort_by { |hour| hour }
```

This code snippet consumes the CSV and process it using ruby.
This reveals the following:

``` ruby
[[0,  {:fraud=>24, :legit=>109, :ratio=>18.05, :average_legit=>499.1, :average_fraud=>1090.1}],
 [1,  {:fraud=>14, :legit=>97, :ratio=>12.61, :average_legit=>637.45, :average_fraud=>1201.6}],
 [2,  {:fraud=>18, :legit=>43, :ratio=>29.51, :average_legit=>636.38, :average_fraud=>1501.61}],
 [3,  {:fraud=> 4, :legit=>26, :ratio=>13.33, :average_legit=>354.72, :average_fraud=>1455.43}],
 [4,  {:fraud=> 0, :legit=> 7, :ratio=> 0.0, :average_legit=>370.75, :average_fraud=> 0}],
 [5,  {:fraud=> 0, :legit=> 4, :ratio=> 0.0, :average_legit=>425.06, :average_fraud=> 0}],
 [6,  {:fraud=> 1, :legit=> 1, :ratio=>50.0, :average_legit=>1.3, :average_fraud=>263.93}],
 [8,  {:fraud=> 0, :legit=> 3, :ratio=> 0.0, :average_legit=>558.93, :average_fraud=> 0}],
 [9,  {:fraud=> 0, :legit=> 7, :ratio=> 0.0, :average_legit=>247.08, :average_fraud=> 0}],
 [10, {:fraud=> 0, :legit=>29, :ratio=> 0.0, :average_legit=>544.99, :average_fraud=> 0}],
 [11, {:fraud=> 5, :legit=>88, :ratio=> 5.38, :average_legit=>789.34, :average_fraud=>1618.57}],
 [12, {:fraud=> 9, :legit=>102, :ratio=>8.11, :average_legit=>672.08, :average_fraud=>1619.23}],
 [13, {:fraud=>11, :legit=>184, :ratio=>5.64, :average_legit=>712.42, :average_fraud=>1458.47}],
 [14, {:fraud=>16, :legit=>231, :ratio=>6.48, :average_legit=>637.13, :average_fraud=>1138.51}],
 [15, {:fraud=>18, :legit=>221, :ratio=>7.53, :average_legit=>767.95, :average_fraud=>1122.72}],
 [16, {:fraud=>30, :legit=>248, :ratio=>10.79, :average_legit=>674.11, :average_fraud=>1390.48}],
 [17, {:fraud=>31, :legit=>240, :ratio=>11.44, :average_legit=>793.65, :average_fraud=>1702.95}],
 [18, {:fraud=>23, :legit=>255, :ratio=>8.27, :average_legit=>725.62, :average_fraud=>1743.69}],
 [19, {:fraud=>44, :legit=>218, :ratio=>16.79, :average_legit=>572.88, :average_fraud=>1691.87}],
 [20, {:fraud=>37, :legit=>235, :ratio=>13.6, :average_legit=>607.99, :average_fraud=>1310.45}],
 [21, {:fraud=>42, :legit=>185, :ratio=>18.5, :average_legit=>739.39, :average_fraud=>1232.22}],
 [22, {:fraud=>29, :legit=>134, :ratio=>17.79, :average_legit=>608.79, :average_fraud=>1765.7}],
 [23, {:fraud=>35, :legit=>141, :ratio=>19.89, :average_legit=>686.13, :average_fraud=>1560.43}]]
```
which reveals that, proportionally, after 19h till the start of 4h, we have a spike in frauds in this period.
Also, the averages of a fraud is always above 1000, which can be used as a base for a cap value for this period.

It's rather unusual for big purchases after midnight, but not so much from 19h to 22h.
We can have a more lax amount for 19h ~ 22h, using the fraud average for this interval, allowing more legit purchases to have the chance to be fulfilled, but limiting for high values (1366.69). 
After 22h til 03h we can be more restrictive and use the legit average as max amount for this interval, in an attempt to still allow legit purchases (570.43).

### Some stores have way more frauds than others

Since we are working with a small dataset of 3.2k records, we can still see that some `merchants` has way more frauds than others, almost 30% of all frauds are concentrated in 12 merchants (out of 1756, less than 1%).
This suggests that we need to keep track of suspicious merchants and with a track record of frauds, being more rigorous in the approval, and more lenient with newer merchants that has no history.

Although it's hard to really come up with a conclusion, because it just may be that the frauds are commited against big merchants, like amazon.

## In addition to the spreadsheet data, what other data would you look at to try to find patterns of possible frauds?

If possible, it would be better to cross the user information with previous records of purchases.
For example, for a given person that had his last purchase in a given region, it's highly unlikely that that person will by something that will be delivered abroad (although we can't discard the possibility that this purchase is a gift for someone abroad or something).
By crossing data of that person purchase history, we can preemptively block a purchase that has no characteristics of the usual purchases. 
