# card.io Android NDK makefile
#
# See the file "LICENSE.md" for the full license governing this code.
#
# Builds these targets:
# - Static library for ARMv7 with NEON vector coprocessor
# - Static library for ARMv8 (most devices)

LOCAL_PATH := $(call my-dir)
LOCAL_DMZ_DIR := card.io-dmz

# --- declare opencv prebuilt static libs ---------------------------------
ifneq (,$(filter $(TARGET_ARCH_ABI),armeabi-v7a arm64-v8a))

include $(CLEAR_VARS)
LOCAL_MODULE := opencv_core
LOCAL_SRC_FILES := lib/$(TARGET_ARCH_ABI)/libopencv_core.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := opencv_imgproc
LOCAL_SRC_FILES := lib/$(TARGET_ARCH_ABI)/libopencv_imgproc.so
LOCAL_SHARED_LIBRARIES := opencv_core
include $(PREBUILT_SHARED_LIBRARY)

endif

# --- libcardioRecognizer.so --------------------------------------------------------
# (neon version)

ifeq (1,1)

include $(CLEAR_VARS)
ifneq (,$(filter $(TARGET_ARCH_ABI),armeabi-v7a arm64-v8a))

LOCAL_MODULE := cardioRecognizer
LOCAL_LDLIBS := -llog -L$(SYSROOT)/usr/lib -lz -ljnigraphics
LOCAL_SHARED_LIBRARIES := cpufeatures opencv_core opencv_imgproc

LOCAL_C_INCLUDES := $(LOCAL_PATH)/$(LOCAL_DMZ_DIR) $(LOCAL_PATH)/$(LOCAL_DMZ_DIR)/cv
LOCAL_SRC_FILES := $(LOCAL_DMZ_DIR)/dmz_all.cpp nativeRecognizer.cpp

LOCAL_CPPFLAGS := -DSCAN_EXPIRY=1

ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)
LOCAL_CPPFLAGS += -DANDROID_HAS_NEON=1
LOCAL_ARM_NEON := true
endif

ifneq (,$(filter $(TARGET_ARCH_ABI), arm64-v8a))
LOCAL_CFLAGS += -DANDROID_HAS_NEON=0 ## 64-bit changed register names - requires asm fixes
endif

include $(BUILD_SHARED_LIBRARY)
endif

endif

# --- libcardioDecider.so ------------------------------------------------------------

ifneq (,$(filter $(TARGET_ARCH_ABI), armeabi armeabi-v7a arm64-v8a))

include $(CLEAR_VARS)

LOCAL_MODULE := cardioDecider
LOCAL_LDLIBS := -llog 
LOCAL_SHARED_LIBRARIES := cpufeatures

LOCAL_C_INCLUDES := $(LOCAL_PATH)/$(LOCAL_DMZ_DIR) 
LOCAL_SRC_FILES := $(LOCAL_DMZ_DIR)/processor_support.cpp nativeDecider.cpp

LOCAL_CFLAGS := -DANDROID_DMZ=1 -DANDROID_HAS_NEON=1

include $(BUILD_SHARED_LIBRARY)
endif

# ------------

$(call import-module,android/cpufeatures)

