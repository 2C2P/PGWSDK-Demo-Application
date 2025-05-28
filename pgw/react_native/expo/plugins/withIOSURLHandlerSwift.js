/*
* Created by DavidBilly 27/5/2025
*/

const { withAppDelegate } = require('@expo/config-plugins');

module.exports = function withIOSURLHandler(config) {
    return withAppDelegate(config, (config) => {

        const importStatement = 'import PGWHelper';

        if (!config.modResults.contents.includes(importStatement)) {
          config.modResults.contents = `${importStatement}\n${config.modResults.contents}`;
        }

        const existingMethod = config.modResults.contents.match(
          /(public override func application\(\n\s*_\s+app:\s+UIApplication,\n\s*open\s+url:\s+URL,\n\s*options:\s+\[UIApplication\.OpenURLOptionsKey:\s+Any\]\s*=\s*\[:\]\n\s*\)\s*->\s*Bool\s*\{([\s\S]*?)\})/
        );

        const codeToInjectPrefix = 'if url.host?.caseInsensitiveCompare("2c2p") == .orderedSame\t{\t\n\t\t';
        const codeToInject = '\tPGWSDKHelper.shared.universalPaymentResultObserver(url: url)\n\t';
        const codeToInjectSuffix = '\t\treturn true\n\t\t}\n\t\t';

        if (existingMethod) {
          config.modResults.contents = config.modResults.contents.replace(
            existingMethod[1],
            injectCode(existingMethod[1], 'return super.application', (codeToInjectPrefix + codeToInject + codeToInjectSuffix))
          );
        } else {
          config.modResults.contents = injectCode(config.modResults.contents, 'var reactNativeDelegate: ExpoReactNativeFactoryDelegate?' ,`public override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
\t${codeToInject} \treturn true\t\n\t}\n\n\t`);
        }

        return config;
    });
};

function injectCode(search, find, insert) {
  var n = search.lastIndexOf(find);
  if (n < 0) return search;
  return search.substring(0, n) + insert + search.substring(n);    
}
