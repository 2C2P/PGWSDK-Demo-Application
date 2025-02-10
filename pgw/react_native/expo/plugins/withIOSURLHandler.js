/*
* Created by DavidBilly 15/1/2025
*/

const { withAppDelegate } = require('@expo/config-plugins');

module.exports = function withIOSURLHandler(config) {
    return withAppDelegate(config, (config) => {

        const importStatement = '#import <PGWHelper/PGWHelper-Swift.h>';

        if (!config.modResults.contents.includes(importStatement)) {
          config.modResults.contents = `${importStatement}\n${config.modResults.contents}`;
        }

        const existingMethod = config.modResults.contents.match(
            /(- \(BOOL\)application:\(UIApplication \*\)application openURL:\(NSURL \*\)url options:\(NSDictionary<UIApplicationOpenURLOptionsKey,id> \*\)options \{[\s\S]*?\})/
        );

        const codeToInjectPrefix = 'if ([url.host caseInsensitiveCompare:@"2c2p"] == NSOrderedSame)\n\t{\t\n\t\t';
        const codeToInject = '[[PGWSDKHelper shared] universalPaymentResultObserverWithURL: url];\n\t';
        const codeToInjectSuffix = '\treturn YES;\n\t}\n\t';

        if (existingMethod) {
          config.modResults.contents = config.modResults.contents.replace(
            existingMethod[1],
            injectCode(existingMethod[1], 'return [', (codeToInjectPrefix + codeToInject + codeToInjectSuffix))
          );
        } else {
          config.modResults.contents = injectCode(config.modResults.contents, '@end' ,`- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options \n{
\t${codeToInject}return YES;
}\n\n`);
        }

        return config;
    });
};

function injectCode(search, find, insert) {
  var n = search.lastIndexOf(find);
  if (n < 0) return search;
  return search.substring(0, n) + insert + search.substring(n);    
}
