package com.ccpp.pgw.sdk.android.demo.application

import android.app.Application
import com.ccpp.pgw.sdk.android.builder.PGWSDKParamsBuilder
import com.ccpp.pgw.sdk.android.core.PGWSDK
import com.ccpp.pgw.sdk.android.enums.APIEnvironment

/**
 * Created by DavidBilly PK on 23/12/24.
 */
class CustomApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        //Reference: https://developer.2c2p.com/docs/sdk-initial-sdk
        PGWSDK.initialize(PGWSDKParamsBuilder(this, APIEnvironment.Sandbox).log(true).build())
    }
}