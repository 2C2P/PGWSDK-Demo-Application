package com.ccpp.softpos.sdk.android.demo.helper;

import android.util.Base64;
import android.util.Log;

import com.ccpp.pgw.sdk.android.model.Constants;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.cfg.MapperConfig;
import com.fasterxml.jackson.databind.introspect.AnnotatedField;
import com.fasterxml.jackson.databind.introspect.AnnotatedMethod;

/**
 * Created by DavidBilly PK on 27/9/18.
 */
public class StringHelper {

    private final static String TAG = StringHelper.class.getName();
    private final String CHARSET = "UTF-8";

    public String base64Encode(final byte[] input) {

        try {

            return new String(
                    Base64.encode(input, Base64.URL_SAFE | Base64.NO_PADDING | Base64.NO_CLOSE | Base64.NO_WRAP),
                    CHARSET
            ).trim();
        } catch (Exception e) {

            e.printStackTrace();

            return null;
        }
    }

    public static String toJson(Object object) {

        try {

            ObjectMapper mapper = new ObjectMapper();
            mapper.configure(SerializationFeature.FAIL_ON_EMPTY_BEANS, false);
            mapper.setPropertyNamingStrategy(new CustomPropertyNamingStrategy());

            return mapper.writerWithDefaultPrettyPrinter().writeValueAsString(object);
        } catch (Exception e) {

            e.printStackTrace();

            return "{}";
        }
    }

    public static void longLog(String veryLongString) {
        int MAX_LOG_LENGTH = 4000;

        // Split by line, then ensure each line can fit into Log's maximum
        // length.
        for (int i = 0, length = veryLongString.length(); i < length; i++) {
            int newline = veryLongString.indexOf('\n', i);
            newline = newline != -1 ? newline : length;
            do {
                int end = Math.min(newline, i + MAX_LOG_LENGTH);
                Log.d(TAG, veryLongString.substring(i, end));
                i = end;
            } while (i < newline);
        }
    }

    private static class CustomPropertyNamingStrategy extends PropertyNamingStrategy {

        @Override
        public String nameForField(MapperConfig<?> config, AnnotatedField field, String defaultName) {

            return convert(defaultName);
        }

        @Override
        public String nameForGetterMethod(MapperConfig<?> config, AnnotatedMethod method, String defaultName) {

            return convert(defaultName);
        }

        @Override
        public String nameForSetterMethod(MapperConfig<?> config, AnnotatedMethod method, String defaultName) {

            return convert(defaultName);
        }

        private String convert(String input) {

            if(input.equalsIgnoreCase(Constants.JSON_NAME_FX_RATE_ID_IDENTICAL)) {

                return Constants.JSON_NAME_FX_RATE_ID_IDENTICAL;
            } else if(input.equalsIgnoreCase(Constants.JSON_NAME_FX_RATES)) {

                return Constants.JSON_NAME_FX_RATES;
            } else if(input.equalsIgnoreCase(Constants.JSON_NAME_QR_DATA)) {

                return Constants.JSON_NAME_QR_DATA;
            } else {

                return input;
            }
        }
    }
}

