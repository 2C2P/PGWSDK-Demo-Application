/*
* Created by DavidBilly PK on 17/1/25.
*/

import React from 'react';
import { FlashList } from '@shopify/flash-list';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import * as InfoApi from '../apis/infoAPI';
import Constants from '../apis/constants';
import Item from '../components/listItem';
import { Platform } from 'react-native';

export default function InfoScreen() {

    const list = [
        {
            id: '1',
            title: Constants.apiClientId.title,
            description: Constants.apiClientId.description,
            method: () => { InfoApi.clientId() }
        },
        {
            id: '2',
            title: Constants.apiConfiguration.title,
            description: Constants.apiConfiguration.description,
            method: () => { InfoApi.configuration() }
        },
        {
            id: '3',
            title: Constants.apiPaymentOption.title,
            description: Constants.apiPaymentOption.description,
            method: () => { InfoApi.paymentOption() }
        },
        {
            id: '4',
            title: Constants.apiPaymentOptionDetail.title,
            description: Constants.apiPaymentOptionDetail.description,
            method: () => { InfoApi.paymentOptionDetail() }
        },
        {
            id: '5',
            title: Constants.apiCustomerTokenInfo.title,
            description: Constants.apiCustomerTokenInfo.description,
            method: () => { InfoApi.customerTokenInfo() }
        },
        {
            id: '6',
            title: Constants.apiExchangeRate.title,
            description: Constants.apiExchangeRate.description,
            method: () => { InfoApi.exchangeRate() }
        },
        {
            id: '7',
            title: Constants.apiUserPreference.title,
            description: Constants.apiUserPreference.description,
            method: () => { InfoApi.userPreference() }
        },
        {
            id: '8',
            title: Constants.apiTransactionStatus.title,
            description: Constants.apiTransactionStatus.description,
            method: () => { InfoApi.transactionStatus() }
        },
        {
            id: '9',
            title: Constants.apiSystemInitialization.title,
            description: Constants.apiSystemInitialization.description,
            method: () => { InfoApi.systemInitialization() }
        },
        {
            id: '10',
            title: Constants.apiPaymentNotification.title,
            description: Constants.apiPaymentNotification.description,
            method: () => { InfoApi.paymentNotification() }
        },
        {
            id: '11',
            title: Constants.apiCancelTransaction.title,
            description: Constants.apiCancelTransaction.description,
            method: () => { InfoApi.cancelTransaction() }
        },
        {
            id: '12',
            title: Constants.apiLoyaltyPointInfo.title,
            description: Constants.apiLoyaltyPointInfo.description,
            method: () => { InfoApi.loyaltyPointInfo() }
        }
    ];

    return (
        <GestureHandlerRootView style={{ flex: 1, paddingBottom: Platform.OS === 'ios' ? 100 : 0 }}>
            <FlashList
                data={list}
                renderItem={({ item }) => <Item icon={'exclamationmark.octagon'} title={item.title} description={item.description} method={item.method} />}
                estimatedItemSize={(list.length + 1)}
                keyExtractor={item => item.id}
            />
        </GestureHandlerRootView>
    );
}