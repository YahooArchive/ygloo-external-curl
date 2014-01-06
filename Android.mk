LOCAL_PATH:= $(call my-dir)

include $(LOCAL_PATH)/config.mk

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

# Some source files would generate empty object, due to our build
# options. Filter them from list of sources to prevent annoying
# warning in libtool on MacOSX
CIGNORES := \
    amigaos.c asyn-ares.c curl_darwinssl.c \
    curl_gssapi.c curl_multibyte.c curl_rtmp.c curl_schannel.c curl_sspi.c \
    cyassl.c ftp.c ftplistparser.c gtls.c hostip6.c hostsyn.c \
    http_negotiate.c http_negotiate_sspi.c idn_win32.c imap.c \
    inet_ntop.c inet_pton.c krb4.c krb5.c ldap.c \
    md4.c memdebug.c non-ascii.c nss.c openldap.c \
    pingpong.c polarssl.c polarssl_threadlock.c pop3.c \
    qssl.c rtsp.c security.c smtp.c socks_gssapi.c socks_sspi.c \
    ssh.c strdup.c strtok.c strtoofft.c telnet.c tftp.c

ifneq ($(CURL_CONFIG_SSL),axtls)
CIGNORES += axtls.c
endif
ifneq ($(CURL_CONFIG_SSL),openssl)
CIGNORES += ssluse.c
CIGNORES += curl_ntlm.c curl_ntlm_core.c curl_ntlm_msgs.c curl_ntlm_wb.c
endif

CURL_SRC_FILES := $(addprefix lib/,$(filter-out $(CIGNORES),$(CSOURCES)))
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
ifeq ($(CURL_CONFIG_SSL),openssl)
LOCAL_CFLAGS += -DUSE_SSLEAY=1 -DUSE_OPENSSL=1
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../openssl/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../axtls/yahoo_certs
endif
ifeq ($(CURL_CONFIG_SSL),axtls)
LOCAL_CFLAGS += -DUSE_AXTLS=1
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
