ARCHS := arm64 arm64e
TARGET := iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES := F1X3R

include $(THEOS)/makefiles/common.mk

GIT_TAG_SHORT := $(shell git describe --tags --always --abbrev=0)
APPLICATION_NAME := F1X3R

#Remade by https://t.me/andrdevv
#Remade by https://github.com/andrd3v

F1X3R_USE_MODULES := 0
F1X3R_FILES += $(wildcard objc_base/*.mm objc_base/*.m)
F1X3R_FILES += $(wildcard cheat/*.mm cheat/*.m)
F1X3R_FILES += imgui/ImGuiDrawView.mm
F1X3R_FILES += $(wildcard imgui/IMGUI/*.cpp)
F1X3R_FILES += $(wildcard imgui/IMGUI/*.mm)

F1X3R_CFLAGS += -fobjc-arc -Wno-unused-function -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-module-import-in-extern-c -Wno-mismatched-return-types -Wno-error=nontrivial-memcall -Wno-nontrivial-memcall
F1X3R_CFLAGS += -Iinclude
F1X3R_CFLAGS += -Iimgui
F1X3R_CFLAGS += -include hud-prefix.pch
F1X3R_CCFLAGS += -DNOTIFY_LAUNCHED_HUD=\"ch.xxtou.notification.hud.launched\"
F1X3R_CCFLAGS += -DNOTIFY_DISMISSAL_HUD=\"ch.xxtou.notification.hud.dismissal\"
F1X3R_CCFLAGS += -DNOTIFY_RELOAD_HUD=\"ch.xxtou.notification.hud.reload\"
F1X3R_CCFLAGS += -DNOTIFY_RELOAD_APP=\"ch.xxtou.notification.app.reload\"
F1X3R_CCFLAGS += -std=c++17
MainApplication.mm_CCFLAGS += -std=c++14

F1X3R_FRAMEWORKS += CoreGraphics QuartzCore UIKit Foundation Metal MetalKit

# ย้ายสองตัวที่มีปัญหามาหลอก Linker ตรงนี้แทนเพื่อไม่ให้บ่นตอนหาไฟล์ไม่เจอ
F1X3R_LDFLAGS += -Xlinker -weak_framework -Xlinker BackBoardServices -Xlinker -weak_framework -Xlinker GraphicsServices
F1X3R_PRIVATE_FRAMEWORKS += IOKit SpringBoardServices

ifeq ($(TARGET_CODESIGN),ldid)
F1X3R_CODESIGN_FLAGS += -Sent.plist
else
F1X3R_CODESIGN_FLAGS += --entitlements ent.plist $(TARGET_CODESIGN_FLAGS)
endif

include $(THEOS_MAKE_PATH)/application.mk

after-stage::
	$(ECHO_NOTHING)mkdir -p packages $(THEOS_STAGING_DIR)/Payload$(ECHO_END)
	$(ECHO_NOTHING)cp -rp $(THEOS_STAGING_DIR)/Applications/F1X3R.app $(THEOS_STAGING_DIR)/Payload$(ECHO_END)
	$(ECHO_NOTHING)cd $(THEOS_STAGING_DIR); zip -qr F1X3R_${GIT_TAG_SHORT}.tipa Payload; cd -;$(ECHO_END)
	$(ECHO_NOTHING)mv $(THEOS_STAGING_DIR)/F1X3R_${GIT_TAG_SHORT}.tipa packages/F1X3R_${GIT_TAG_SHORT}.tipa $(ECHO_END)
