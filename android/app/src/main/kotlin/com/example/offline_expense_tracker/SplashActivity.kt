package com.example.offline_expense_tracker

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.airbnb.lottie.LottieAnimationView

class SplashActivity : AppCompatActivity() {
    
    private val TAG = "SplashActivity"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        try {
            // Try to use Lottie layout first, fallback to simple layout
            try {
                setContentView(R.layout.splash_view)
            } catch (e: Exception) {
                Log.w(TAG, "Failed to load Lottie layout, using simple layout: ${e.message}")
                setContentView(R.layout.splash_view_simple)
            }
            
            // Hide action bar
            supportActionBar?.hide()
            
            // Get references to the views
            val animationView = findViewById<LottieAnimationView>(R.id.animation_view)
            val appIcon = findViewById<ImageView>(R.id.app_icon)
            val appName = findViewById<TextView>(R.id.app_name)
            val appSubtitle = findViewById<TextView>(R.id.app_subtitle)
            
            // Configure the Lottie animation safely (if it exists)
            if (animationView != null) {
                try {
                    animationView.apply {
                        // Set animation properties
                        speed = 1.0f
                        repeatCount = 0 // Don't loop
                    }
                    Log.d(TAG, "Lottie animation configured successfully")
                } catch (e: Exception) {
                    Log.e(TAG, "Error configuring Lottie animation: ${e.message}")
                }
            } else {
                Log.d(TAG, "No Lottie animation view found, using simple layout")
            }
            
            // Start animations after a short delay
            Handler(Looper.getMainLooper()).postDelayed({
                startAnimations(appIcon, appName, appSubtitle)
            }, 500)
            
            // Start main activity after 3 seconds
            Handler(Looper.getMainLooper()).postDelayed({
                startMainActivity()
            }, 3000)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error in onCreate: ${e.message}")
            // If splash fails, go directly to main activity
            startMainActivity()
        }
    }
    
    private fun startAnimations(appIcon: ImageView?, appName: TextView?, appSubtitle: TextView?) {
        // Animate app icon (if it exists)
        appIcon?.apply {
            scaleX = 0f
            scaleY = 0f
            animate()
                .scaleX(1f)
                .scaleY(1f)
                .setDuration(600)
                .setStartDelay(0)
                .start()
        }
        
        // Animate app name
        appName?.apply {
            alpha = 0f
            translationY = 50f
            animate()
                .alpha(1f)
                .translationY(0f)
                .setDuration(800)
                .setStartDelay(300)
                .start()
        }
        
        // Animate app subtitle
        appSubtitle?.apply {
            alpha = 0f
            translationY = 30f
            animate()
                .alpha(0.9f)
                .translationY(0f)
                .setDuration(800)
                .setStartDelay(600)
                .start()
        }
    }
    
    private fun startMainActivity() {
        try {
            if (!isFinishing) {
                val intent = Intent(this, MainActivity::class.java)
                startActivity(intent)
                finish()
                // Add transition animation
                overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error starting MainActivity: ${e.message}")
            // Force finish this activity
            finish()
        }
    }
} 