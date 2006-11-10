###########
# What to do before running this script:
# - openUp needs to be installed.
# - Set VERSION and BETA below
# - To enable beta, also edit Source/AIAdium.h, and set BETA_RELEASE to TRUE. Set it to FALSE when doing a final release.
# - Edit the following plist keys in Adium_2.plist
#		- CFBundleGetInfoString
#		- CFBundleShortVersionString
#		- CFBundleVersion
#
# How to run this script:
# - make all
###########

VERSION=0.1

###########
# To release!
# First upload to cachefly. If you don't have access and need to do a release, get with Evan or Chris (tick).
# Triggering the version checker once the release is up:
# 1) Build Adium
# 2) Get the number out of the 'buildnum' file in Adium.app/Contents/Resources
# 3) Paste that number into the appropriate place (adium version or adium-beta version, depending on which you're triggering) in the version.plist file in our sf.net ht_docs folder.  You should be able to ftp into shell.sf.net with your sf.net login/pass and then cd to the right directory (/home/groups/a/ad/adium/htdocs)
###########

###########
# No need for changes below this point
###########

SRC_DIR=App
BUILD_DIR=build
ART_DIR=Artwork
ADIUM_DIR=$(BUILD_DIR)/Punakea
RELEASE_NAME=Punakea
ADIUM_BUILD_DIR=../build/Release



all: release

clean:
	rm -rf $(BUILD_DIR)

release: createfolder diskimage

createfolder:
	@# clean build directory
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)

	mkdir $(ADIUM_DIR)
	
	@# copy the app
	cp -R $(ADIUM_BUILD_DIR)/Punakea.app $(ADIUM_DIR)
	
	@# copy the .DS_Store
	cp Template_DSStore $(ADIUM_DIR)
	mv $(ADIUM_DIR)/Template_DSStore $(ADIUM_DIR)/.DS_Store

	@# copy the text files
	#cp $(SRC_DIR)/Changes.txt $(ADIUM_DIR)
	#cp $(SRC_DIR)/License.txt $(ADIUM_DIR)
	
	@# symlink /Applications
	ln -s /Applications $(ADIUM_DIR)/Applications

	@# delete svn  and backup files
	find $(BUILD_DIR) -name ".svn" -type d -exec rm -rf {} \; -prune
	#find $(BUILD_DIR) \( -name "*~" -or -name .DS_Store \) -type f -delete
	
diskimage:
	# rm "$(BUILD_DIR)/$(RELEASE_NAME).dmg" || true
	@# make Adium disk image
	mkdir -p $(ADIUM_DIR)/.background
	cp $(ART_DIR)/dmgBackground.png $(ADIUM_DIR)/.background
	
	@# Cleanup Frameworks dir
	rm -f $(ADIUM_DIR)/$(RELEASE_NAME).app/Contents/Frameworks/*.h
	rm -f $(ADIUM_DIR)/$(RELEASE_NAME).app/Contents/Frameworks/SLA.r

	./make-diskimage.sh $(BUILD_DIR)/$(RELEASE_NAME).dmg $(ADIUM_DIR) "Punakea" dmg.scpt SLAResources
	
	@echo Build finished
