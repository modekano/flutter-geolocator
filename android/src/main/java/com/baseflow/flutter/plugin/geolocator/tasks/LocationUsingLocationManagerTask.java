package com.baseflow.flutter.plugin.geolocator.tasks;

import android.app.Activity;
import android.content.Context;
import android.location.Location;
import android.location.LocationManager;

import com.baseflow.flutter.plugin.geolocator.Codec;
import com.baseflow.flutter.plugin.geolocator.data.LocationOptions;

import io.flutter.plugin.common.PluginRegistry;

abstract class LocationUsingLocationManagerTask extends Task {
    private static final long TWO_MINUTES = 120000;

    private final Context mContext;
    final LocationOptions mLocationOptions;

    LocationUsingLocationManagerTask(TaskContext context) {
        super(context);

        PluginRegistry.Registrar registrar = context.getRegistrar();

        mContext = registrar.activity() != null ? registrar.activity() : registrar.activeContext();
        mLocationOptions = Codec.decodeLocationOptions(context.getArguments());
    }

    public abstract void startTask();

    LocationManager getLocationManager() {
        return (LocationManager) mContext.getSystemService(Activity.LOCATION_SERVICE);
    }

    public static boolean isBetterLocation(Location location, Location bestLocation) {
        if (bestLocation == null)
            return true;

        Long timeDelta = location.getTime() - bestLocation.getTime();

        boolean isSignificantlyNewer = timeDelta > TWO_MINUTES;
        boolean isSignificantlyOlder = timeDelta < -TWO_MINUTES;
        boolean isNewer = timeDelta > 0;

        if (isSignificantlyNewer)
            return true;

        if (isSignificantlyOlder)
            return false;

        float accuracyDelta = (int)(location.getAccuracy() - bestLocation.getAccuracy());
        boolean isLessAccurate = accuracyDelta > 0;
        boolean isMoreAccurate = accuracyDelta < 0;
        boolean isSignificantlyLessAccurate = accuracyDelta > 200;

        boolean isFromSameProvider = false;
        if(location.getProvider() != null) {
            isFromSameProvider = location.getProvider().equals(bestLocation.getProvider());
        }

        if (isMoreAccurate)
            return true;

        if (isNewer && !isLessAccurate)
            return true;

        //noinspection RedundantIfStatement
        if (isNewer && !isSignificantlyLessAccurate && isFromSameProvider)
            return true;

        return false;
    }
}
