# Files needed in <image-dir>/build by the various targets
.SECONDEXPANSION : $(BUILD_FILES)
BUILD_FILES = spotfire-automationservices/build/Spotfire.Dxp.netcore-linux.sdn \
              spotfire-config/build/tss-$(SPOTFIRE_SERVER_VERSION).x86_64.tar.gz \
              spotfire-deployment/build/Spotfire.Dxp.sdn \
              spotfire-deployment/build/TIB_sfire_server_$(SPOTFIRE_NETCORE_LANGUAGEPACKS_VERSION)_languagepack-multi.zip \
              spotfire-node-manager/build/tsnm-$(SPOTFIRE_NODEMANAGER_VERSION).x86_64.tar.gz \
              spotfire-pythonservice/build/Spotfire.Dxp.PythonServiceLinux.sdn \
              spotfire-rservice/build/Spotfire.Dxp.RServiceLinux.sdn \
              spotfire-server/build/tss-$(SPOTFIRE_SERVER_VERSION).x86_64.tar.gz \
              spotfire-terrservice/build/Spotfire.Dxp.TerrServiceLinux.sdn \
              spotfire-webplayer/build/Spotfire.Dxp.netcore-linux.sdn \
              spotfire-webplayer/build/TIB_sfire_server_$(SPOTFIRE_NETCORE_LANGUAGEPACKS_VERSION)_languagepack-multi.zip
