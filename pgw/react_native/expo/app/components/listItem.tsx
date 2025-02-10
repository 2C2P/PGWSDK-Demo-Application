/*
* Created by DavidBilly PK on 17/1/25.
*/

import React from 'react';
import {
    View,
    Text,
    StyleSheet,
    Pressable
} from 'react-native';
import { IconSymbol, IconSymbolName } from '@/components/ui/IconSymbol';
import Constants from '../apis/constants';

type ItemProps = {
    icon: IconSymbolName
    title: string
    description: string
    method: () => void;
};

const Item = ({ icon, title, description, method }: ItemProps) => {
    const handlePress = () => {
        method();
    };
    return (
        <View style={styles.container}>
            <View style={styles.containerLeft}>
                <IconSymbol name={icon} color={'grey'} size={25} />
            </View>
            <View style={styles.containerCenter}>
                <Text style={styles.title}>{title}</Text>
                <Text style={styles.description}>{description}</Text>
            </View>
            <View style={styles.containerRight}>
                <Pressable style={styles.button} onPress={handlePress}>
                    <Text>{Constants.titleSubmit}</Text>
                </Pressable>
            </View>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        padding: 10,
        marginVertical: 8,
        marginHorizontal: 16,
        borderColor: 'grey',
        borderRadius: 5,
        flexDirection: 'row',
        backgroundColor: 'white'
    },
    containerLeft: {
        alignItems: 'flex-start',
        justifyContent: 'center'
    },
    containerCenter: {
        alignItems: 'stretch',
        justifyContent: 'center',
        paddingVertical: 10,
        paddingHorizontal: 10,
        flex: 1
    },
    containerRight: {
        alignItems: 'flex-end',
        justifyContent: 'center'
    },
    title: {
        fontSize: 14,
        fontWeight: 'bold'
    },
    description: {
        fontSize: 11,
        color: 'grey',
        paddingTop: 5
    },
    button: {
        alignItems: 'center',
        justifyContent: 'center',
        paddingVertical: 10,
        paddingHorizontal: 10,
        elevation: 3,
        borderRadius: 10,
        backgroundColor: '#dae6f5'
    }
});

export default Item;