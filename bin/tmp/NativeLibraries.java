package com.rhomobile.rhodes;
public class NativeLibraries {
  public static void load() {
    // Load native .so libraries
    System.loadLibrary("plugin");
    // Load native implementation of rhodes
    System.loadLibrary("rhodes");
  }
};
