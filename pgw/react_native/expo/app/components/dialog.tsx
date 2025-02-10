/*
* Created by DavidBilly PK on 17/1/25.
*/

import React, { useState } from 'react';
import { Button, Modal, ScrollView } from 'react-native';
import { Dialog, Text, TextInput } from 'react-native-paper';
import Constants from '../apis/constants';
import * as App from '../_layout';

const CustomDialog = ({ prop }: any) => {
  const [text, setText] = useState(App.paymentToken);
  const handleTextChange = (newText: any) => {
    setText(newText);
  };
  return (
    <Modal visible={prop.visible} onDismiss={App.instance.hideDialog}>
      <Dialog visible={prop.visible} onDismiss={App.instance.hideDialog}>
        <Dialog.Title>{prop.title}</Dialog.Title>
        <Dialog.ScrollArea style={{ maxHeight: 500 }}>
          <ScrollView contentContainerStyle={{ paddingHorizontal: 24 }}>
            {
              prop.editable ? (
                <TextInput
                  onChangeText={handleTextChange}
                  multiline={true}
                  value={text}
                />
              ) : (
                <Text>{prop.message}</Text>
              )
            }
          </ScrollView>
        </Dialog.ScrollArea>
        <Dialog.Actions>
          {prop.editable ? (
            <Button title={Constants.titleOK} onPress={() => { App.updatePaymentToken(text); App.instance.hideDialog(); }} />
          ) : (
            <Button title={Constants.titleClose} onPress={App.instance.hideDialog} />
          )}
        </Dialog.Actions>
      </Dialog>
    </Modal>
  );
};

export default CustomDialog;