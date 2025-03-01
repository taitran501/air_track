import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlatformAuth {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Initialize auth and set up listeners on the main thread
  static Future<void> initialize() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Force auth initialization on main thread
      await _runOnMainThread(() async {
        // Listen to auth state changes on main thread
        _auth.authStateChanges().listen((user) {
          print("Auth state changed on main thread: ${user?.uid ?? 'signed out'}");
        });
        
        return;
      });
    }
  }
  
  static Future<UserCredential> signInAnonymously() async {
    if (kIsWeb) {
      return await _auth.signInAnonymously();
    }
    
    if (Platform.isAndroid || Platform.isIOS) {
      return await _runOnMainThread(() => _auth.signInAnonymously());
    }
    
    return await _auth.signInAnonymously();
  }
  
  static Future<T> _runOnMainThread<T>(Future<T> Function() operation) async {
    final completer = Completer<T>();
    
    if (WidgetsBinding.instance.isRootWidgetAttached) {
      // Use a more direct approach to ensure we're on the main thread
      WidgetsBinding.instance.scheduleFrameCallback((_) async {
        try {
          final result = await operation();
          completer.complete(result);
        } catch (e) {
          completer.completeError(e);
        }
      });
    } else {
      // Fallback if we can't schedule a frame
      try {
        final result = await operation();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    }
    
    return completer.future;
  }
  
  static User? get currentUser => _auth.currentUser;
  
  static Future<void> signOut() async {
    if (kIsWeb) return await _auth.signOut();
    if (Platform.isAndroid || Platform.isIOS) {
      return await _runOnMainThread(() => _auth.signOut());
    }
    return await _auth.signOut();
  }
}