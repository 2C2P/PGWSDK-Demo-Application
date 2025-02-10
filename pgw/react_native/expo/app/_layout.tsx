import React, { useState, useEffect } from 'react';
import { DefaultTheme, ThemeProvider } from '@react-navigation/native';
import { Stack, useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as InfoApi from './apis/infoAPI';
import CustomDialog from './components/dialog';

export let paymentToken: string = 'kSAops9Zwhos8hSTSeLTUYaElfqs/c0w7o0EzksXzc3sm2O/bq4Ukeis59qPyzcayTbVIv50q1wJxPTX1zsTW9AMczgmFmxu8FlQUc5eW+pb2rHkB+907P4aHuzgHwNC';
export const updatePaymentToken = (newValue: string) => {
  paymentToken = newValue;
};
export var instance: any;

export default function RootLayout() {

  const router = useRouter();
  const [modalVisible, setModalVisible] = useState(false);
  const [modalTitle, setModalTitle] = useState('');
  const [modalMessage, setModalMessage] = useState('');
  const [modalEditable, setModalEditable] = useState(false);

  useEffect(() => {
    // Note: Important due to PGW SDK has to initialize before request APIs.
    InfoApi.initialize();
  }, [])

  const showDialog = (title: string, message: string, editable: boolean = false) => {
    setModalEditable(editable);
    setModalVisible(true);
    setModalTitle(title);
    setModalMessage(message);
  };

  const hideDialog = () => {
    setModalVisible(false);
  };

  const webViewScreen = (url: string, responseCode: string) => {
    router.push({
      pathname: '/webview',
      params: { url, responseCode }
    });
  };

  instance = {
    'showDialog': showDialog,
    'hideDialog': hideDialog,
    'webViewScreen': webViewScreen
  };

  const dialogProps = {
    visible: modalVisible,
    title: modalTitle,
    message: modalMessage,
    editable: modalEditable
  };

  return (
    <ThemeProvider value={DefaultTheme}>
      <Stack>
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="+not-found" />
        <Stack.Screen name="webview" />
      </Stack>
      <CustomDialog prop={dialogProps} />
      <StatusBar style="auto" />
    </ThemeProvider>
  );
};