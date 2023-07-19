# Explanations

## Explain the money flow and the information flow in the acquirer market and the role of the main players.

A simple diagram is:

  ┌──────────────────┐
  │     Merchant     │
  └──────┬───────────┘
       A │   ▲
         ▼   │ E
  ┌──────────┴───────┐
  │  Payment Gateway │
  └──────┬───────────┘
       B │   ▲
         ▼   │ E
  ┌──────────┴───────┐
  │     Acquirer     │
  └──────┬───────────┘
       C │   ▲
         ▼   │ E
  ┌──────────┴───────┐
  │    Card Brand    │
  └──────┬───┬───────┘
       D │   │
         ▼   │ E
  ┌──────────┴───────┐
  │   Issuing Bank   │
  └──────────────────┘

A. The customer decides to pay for the products/service and choses a payment method, fills all the information, and confirms the purchase.

B. The store will interact only with the payment gateway, and the gateway will hide all the steps that are required for a payment to be fulfilled. 

C. The Acquirer receives all the payment information from the gateway and will process it to fulfill this payment. 
Then, it moves the request to the Card Brand, which will decide some business rules, such as regardings installment plans, how and where your card can be used, etc.

D. Finally, the payment reaches the Issuing Bank, which will check for funds or limit, perofmr credit analysis and approve or deny the payment.

E. The payment fullfilled is returned all the way back to the customer, so they know if the purchased was approved or denied.

Resources:
  - https://www.ebanx.com/en/resources/payments-explained/acquiring-bank/
  - https://help.vtex.com/tutorial/credit-card-basic-payment-flow

## Explain the difference between acquirer, sub-acquirer and payment gateway and how the flow explained in question 1 changes for these players.

An Acquirer is a company that specializes in processing payments, allowing a merchant to offer many different types of payment to a customer. It receives the payment information, process it and foward this request to the Card Issuer or Issuing Bank. In order for the acquirer to receive this payment information, it must be connected to the merchant payment gateway. Examples: Stone, Cielo

A Sub-Acquirer is also a company that specializes in processing payments, but perfoming only a subset of functionalities of an Acquirer. By not perfoming all steps, it reduces the implementation cost for such companies resulting in low costs, being a good alternative for small stores. Although, these players usually charge high rates for profit, so this trade-off must be considered by the merchant. Examples: PagSeguro, Paypal

The Gateway, as said, is just a system that sits between the merchant and the rest of the payment system. It's a way to abstract away all the complexity of a payment system for a merchant to integrate with.

## Explain what chargebacks are, how they differ from cancellations and what is their connection with fraud in the acquiring world.

Chargeback is the act of a customer filing for the return of their funds once the payment is fulfiled. It's usually a dispute between the merchant and the customer, and the reasons can be one of:
- Product not as described, like a poorly advertised product that tricked the customer into buying it.
- Product not delivered to customer
- Payment with value different from the agreed price
- Non authorized payment

Between the justifiable reasons a customer can have for a chargeback, there are many that can have malicious intent, like:

- Product received but customer claims it never was delivered
- Product is as described, but customer claims otherwise.

Besides dishonest customers, the chargeback is a way to protect the customer of frauds.
Frauds can happen when someone steals your credit card information and perform purchases using your funds.
To avoid that, the payment system must implement anti-frauds mechanism to reject the payment request in case of suspicious purchases.

A cancellation, on the other hand, can happend before funds are transfered from/to the issuing bank. 
It's an agreed action between merchant/customer and less complex than filing for a chargeback.

Resources: 
  - https://www.ebanx.com/en/resources/payments-explained/chargeback/
  - https://vtex.com/pt-br/blog/gestao/chargeback-em-loja-virtual-o-que-e-e-como-funciona/
  - https://blog.appmax.com.br/nao-confunda-mais-chargeback-e-estorno/
  - https://mahmutgulerce.com/fintech-101-difference-between-cancel-refund-chargeback/

## Glossary

- Card Brand / Card Network
Are the players that manage and promote the cards. They also regulates how, who, where the cards can be used.
Ex. Visa, Mastercard

- Card Issuer
Financial institution (like a bank) that provides the card for you to use your resources at the bank.
Allowing or denying a card, managing your account and resources are one of the many responsabilities of the card issuer.
Ex. Bradesco, Itaú, Nubank, C6, etc

- Chargeback
The act of a customer requesting their money back, directly with the bank.
This happens for many reasons: Payment error, fraud or commercial disagreement.
This exists to protect customer. 

- Acquirer Bank / Acquirer / Credit Card Bank
In payment flow context, is the institution sitting between customer and merchant to handle payments.
It will receive a request for payment from a customer to a merchant, will ask authorization to the issuer bank and once valid, will transfer funds from customer to merchant.

- Payment Gateway
A system that transmits data from purchases made in your store at checkout, an intermediary between an e-commerce and its payment method used