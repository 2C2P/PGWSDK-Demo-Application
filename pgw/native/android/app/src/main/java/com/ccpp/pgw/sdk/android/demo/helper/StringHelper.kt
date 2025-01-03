package com.ccpp.pgw.sdk.android.demo.helper

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.SerializationFeature

/**
 * Created by DavidBilly PK on 23/12/24.
 */
object StringHelper {

    fun toJson(`object`: Any?): String = try {

        ObjectMapper().apply {
            configure(SerializationFeature.FAIL_ON_EMPTY_BEANS, false)
        }.writerWithDefaultPrettyPrinter().writeValueAsString(`object`)
    } catch (e: Exception) {

        e.printStackTrace()

        "{}"
    }
}

