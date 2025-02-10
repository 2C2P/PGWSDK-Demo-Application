/*
* Created by DavidBilly 15/1/2025
*/

const { withGradleProperties } = require('@expo/config-plugins');

module.exports = function withAndroidABIFilters(config) {
    return withGradleProperties(config, (config) => {
        config.modResults = config.modResults.map(item => {
            if (item.type === 'property' && item.key === 'reactNativeArchitectures') {
                return { ...item, value: 'armeabi-v7a,arm64-v8a,x86_64' };
            }
            return item;
        });
        return config;
    });
};