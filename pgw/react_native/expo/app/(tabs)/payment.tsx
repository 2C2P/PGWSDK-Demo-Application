/*
* Created by DavidBilly PK on 20/1/25.
*/

import React from 'react';
import { FlashList } from '@shopify/flash-list';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import * as PaymentApi from '../apis/paymentAPI';
import Constants from '../apis/constants';
import Item from '../components/listItem';
import { Platform } from 'react-native';

export default function PaymentScreen() {

  const list = [
    {
      id: '1',
      title: Constants.paymentUI.title,
      description: Constants.paymentUI.description,
      method: () => { PaymentApi.paymentUI() }
    },
    {
      id: '2',
      title: Constants.paymentGlobalCreditDebitCard.title,
      description: Constants.paymentGlobalCreditDebitCard.description,
      method: () => { PaymentApi.globalCreditDebitCard() }
    },
    {
      id: '3',
      title: Constants.paymentLocalCreditDebitCard.title,
      description: Constants.paymentLocalCreditDebitCard.description,
      method: () => { PaymentApi.localCreditDebitCard() }
    },
    {
      id: '4',
      title: Constants.paymentCustomerTokenization.title,
      description: Constants.paymentCustomerTokenization.description,
      method: () => { PaymentApi.customerTokenization() }
    },
    {
      id: '5',
      title: Constants.paymentCustomerTokenizationWithoutAuthorisation.title,
      description: Constants.paymentCustomerTokenizationWithoutAuthorisation.description,
      method: () => { PaymentApi.customerTokenizationWithoutAuthorisation() }
    },
    {
      id: '6',
      title: Constants.paymentCustomerToken.title,
      description: Constants.paymentCustomerToken.description,
      method: () => { PaymentApi.customerToken() }
    },
    {
      id: '7',
      title: Constants.paymentGlobalInstallmentPaymentPlan.title,
      description: Constants.paymentGlobalInstallmentPaymentPlan.description,
      method: () => { PaymentApi.globalInstallmentPaymentPlan() }
    },
    {
      id: '8',
      title: Constants.paymentLocalInstallmentPaymentPlan.title,
      description: Constants.paymentLocalInstallmentPaymentPlan.description,
      method: () => { PaymentApi.localInstallmentPaymentPlan() }
    },
    {
      id: '9',
      title: Constants.paymentRecurringPaymentPlan.title,
      description: Constants.paymentRecurringPaymentPlan.description,
      method: () => { PaymentApi.recurringPaymentPlan() }
    },
    {
      id: '10',
      title: Constants.paymentThirdPartyPayment.title,
      description: Constants.paymentThirdPartyPayment.description,
      method: () => { PaymentApi.thirdPartyPayment() }
    },
    {
      id: '11',
      title: Constants.paymentUserAddressForPayment.title,
      description: Constants.paymentUserAddressForPayment.description,
      method: () => { PaymentApi.userAddressForPayment() }
    },
    {
      id: '12',
      title: Constants.paymentOnlineDirectDebit.title,
      description: Constants.paymentOnlineDirectDebit.description,
      method: () => { PaymentApi.onlineDirectDebit() }
    },
    {
      id: '13',
      title: Constants.paymentDeepLinkPayment.title,
      description: Constants.paymentDeepLinkPayment.description,
      method: () => { PaymentApi.deepLinkPayment() }
    },
    {
      id: '14',
      title: Constants.paymentInternetBanking.title,
      description: Constants.paymentInternetBanking.description,
      method: () => { PaymentApi.internetBanking() }
    },
    {
      id: '15',
      title: Constants.paymentWebPayment.title,
      description: Constants.paymentWebPayment.description,
      method: () => { PaymentApi.webPayment() }
    },
    {
      id: '16',
      title: Constants.paymentPayAtCounter.title,
      description: Constants.paymentPayAtCounter.description,
      method: () => { PaymentApi.payAtCounter() }
    },
    {
      id: '17',
      title: Constants.paymentSelfServiceMachines.title,
      description: Constants.paymentSelfServiceMachines.description,
      method: () => { PaymentApi.selfServiceMachines() }
    },
    {
      id: '18',
      title: Constants.paymentQRPayment.title,
      description: Constants.paymentQRPayment.description,
      method: () => { PaymentApi.qrPayment() }
    },
    {
      id: '19',
      title: Constants.paymentBuyNowPayLater.title,
      description: Constants.paymentBuyNowPayLater.description,
      method: () => { PaymentApi.buyNowPayLater() }
    },
    {
      id: '20',
      title: Constants.paymentDigitalPayment.title,
      description: Constants.paymentDigitalPayment.description,
      method: () => { PaymentApi.digitalPayment() }
    },
    {
      id: '21',
      title: Constants.paymentLinePay.title,
      description: Constants.paymentLinePay.description,
      method: () => { PaymentApi.linePay() }
    },
    {
      id: '22',
      title: Constants.paymentApplePay.title,
      description: Constants.paymentApplePay.description,
      method: () => { PaymentApi.applePay() }
    },
    {
      id: '23',
      title: Constants.paymentGooglePay.title,
      description: Constants.paymentGooglePay.description,
      method: () => { PaymentApi.googlePay() }
    },
    {
      id: '24',
      title: Constants.paymentCardLoyaltyPointPayment.title,
      description: Constants.paymentCardLoyaltyPointPayment.description,
      method: () => { PaymentApi.cardLoyaltyPointPayment() }
    },
    {
      id: '25',
      title: Constants.paymentZaloPay.title,
      description: Constants.paymentZaloPay.description,
      method: () => { PaymentApi.zaloPay() }
    },
    {
      id: '26',
      title: Constants.paymentCryptocurrency.title,
      description: Constants.paymentCryptocurrency.description,
      method: () => { PaymentApi.cryptocurrency() }
    },
    {
      id: '27',
      title: Constants.paymentWebPaymentCard.title,
      description: Constants.paymentWebPaymentCard.description,
      method: () => { PaymentApi.webPaymentCard() }
    }
  ];

  return (
    <GestureHandlerRootView style={{ flex: 1, paddingBottom: Platform.OS === 'ios' ? 100 : 0 }}>
      <FlashList
        data={list}
        renderItem={({ item }) => <Item icon={'cart'} title={item.title} description={item.description} method={item.method} />}
        estimatedItemSize={(list.length + 1)}
        keyExtractor={item => item.id}
      />
    </GestureHandlerRootView>
  );
}
