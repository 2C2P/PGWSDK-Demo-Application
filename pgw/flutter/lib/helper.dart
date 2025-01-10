import 'dart:convert';

/*
 * Created by DavidBilly PK on 9/1/25.
 */
String prettyJson(dynamic json, {int indent = 2}) {

  var spaces = ' ' * indent;
  var encoder = JsonEncoder.withIndent(spaces);

  return encoder.convert(json);
}