package com.ccpp.softpos.sdk.android.demo.app

import android.app.Application
import com.ccpp.pgw.sdk.android.builder.PGWSDKParamsBuilder
import com.ccpp.pgw.sdk.android.enums.APIEnvironment
import com.ccpp.softpos.sdk.android.core.SoftPOSSDK

/**
 * Created by DavidBilly PK on 5/6/25.
 */
class CustomApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        val params = PGWSDKParamsBuilder(this, APIEnvironment.Sandbox).log(true).build()
        SoftPOSSDK.initialize(params)
    }
}