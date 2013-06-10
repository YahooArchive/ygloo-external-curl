LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

CURL_CFLAGS += -DHAVE_CONFIG_H

CURL_HEADERS := \
    include/curl/curlbuild.h \
    include/curl/curl.h \
    include/curl/curlrules.h \
    include/curl/curlver.h \
    include/curl/easy.h \
    include/curl/mprintf.h \
    include/curl/multi.h \
    include/curl/stdcheaders.h \
    include/curl/typecheck-gcc.h \
    include/curl/types.h 

include $(LOCAL_PATH)/lib/Makefile.inc
CURL_SRC_FILES := $(addprefix lib/,$(CSOURCES)) 
#CURL_H_FILES := $(addprefix include/curl/,$(CURL_HEADERS)) 

# Static library (with PIC)
include $(CLEAR_VARS)

LOCAL_MODULE:= libyahoo_curl
LOCAL_MODULE_TAGS := optional

LOCAL_SRC_FILES := $(CURL_SRC_FILES)
LOCAL_CFLAGS := $(CURL_CFLAGS)

#LOCAL_ARM_MODE := arm
LOCAL_PRELINK_MODULE := false

# Force compiling the static library as PIC so it can be embedded
# into a shared library later
LOCAL_CFLAGS += -fPIC -DPIC

LOCAL_C_INCLUDES += $(LOCAL_PATH)/include/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/android/

LOCAL_CFLAGS += -DHAVE_LIBZ -DHAVE_ZLIB_H
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../zlib

# SSL provider
ifeq ($(YPERSPACE_CONFIG_SSL),openssl)
LOCAL_CFLAGS += -DUSE_SSLEAY
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../openssl/include
endif
ifeq ($(YPERSPACE_CONFIG_SSL),axtls)
LOCAL_CFLAGS += -DUSE_AXTLS
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../axtls/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../axtls/crypto
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../axtls/ssl
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../axtls/config
endif

ifneq ($(NDK_ROOT),)
LOCAL_LDLIBS += -fuse-ld=gold 
endif
include $(BUILD_STATIC_LIBRARY)

######## 
# include $(CLEAR_VARS) 
# LOCAL_MODULE := curljni 
# LOCAL_SRC_FILES := curljni.c 
# LOCAL_STATIC_LIBRARIES := libcurl 
# LOCAL_C_INCLUDES += $(LOCAL_PATH)/curl/include 
# include $(BUILD_SHARED_LIBRARY) 
