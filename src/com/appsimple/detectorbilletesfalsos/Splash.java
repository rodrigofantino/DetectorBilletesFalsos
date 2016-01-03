package com.appsimple.detectorbilletesfalsos;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
public class Splash extends Activity {

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.splash);


		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

		Thread splashThread = new Thread() {
			@Override
			public void run() {

				try {
					int waited = 0;
					while (waited < 1000) {
						sleep(100);
						waited += 100;
					}
				} catch (InterruptedException e) {
					// do nothing
				} finally {
					finish();
					Intent i = new Intent();
					i.setClassName("com.appsimple.DetectorBilleteFalso",
							"com.appsimple.DetectorBilleteFalso.Menu");
					startActivity(i);
				}
			}
		};
		splashThread.start();

	}

}