# LoginDemo Cross-Platform Makefile
# iOS + Android 통합 빌드 명령어

.PHONY: all build test clean setup ios-build ios-test ios-clean android-build android-test android-clean

# === iOS Commands ===

ios-build:
	@echo "🍎 Building iOS..."
	cd ios && xcodebuild -project LoginDemo.xcodeproj \
		-scheme LoginDemo \
		-sdk iphonesimulator \
		-configuration Debug \
		build

ios-test:
	@echo "🧪 Running iOS tests..."
	cd ios && xcodebuild -project LoginDemo.xcodeproj \
		-scheme LoginDemo \
		-sdk iphonesimulator \
		-destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
		test

ios-clean:
	@echo "🧹 Cleaning iOS..."
	cd ios && xcodebuild -project LoginDemo.xcodeproj clean

ios-release:
	@echo "📦 Building iOS Release..."
	cd ios && xcodebuild -project LoginDemo.xcodeproj \
		-scheme LoginDemo \
		-sdk iphoneos \
		-configuration Release \
		build

# === Android Commands ===

android-build:
	@echo "🤖 Building Android..."
	cd android && ./gradlew assembleDebug

android-test:
	@echo "🧪 Running Android tests..."
	cd android && ./gradlew test

android-clean:
	@echo "🧹 Cleaning Android..."
	cd android && ./gradlew clean

android-release:
	@echo "📦 Building Android Release..."
	cd android && ./gradlew assembleRelease

android-lint:
	@echo "🔍 Running Android lint..."
	cd android && ./gradlew lint

# === Combined Commands ===

build: ios-build android-build
	@echo "✅ Both platforms built successfully"

test: ios-test android-test
	@echo "✅ All tests passed on both platforms"

clean: ios-clean android-clean
	@echo "🧹 Cleaned both platforms"

release: ios-release android-release
	@echo "📦 Release builds completed"

# === Development Setup ===

setup:
	@echo "🔧 Setting up development environment..."
	@echo "Checking iOS..."
	@which xcodebuild > /dev/null || (echo "❌ Xcode not found" && exit 1)
	@echo "✅ Xcode installed"
	@echo "Checking Android..."
	@if [ -d "android" ] && [ -f "android/gradlew" ]; then \
		cd android && ./gradlew --version; \
	else \
		echo "⚠️  Android project not initialized yet"; \
	fi
	@echo "✅ Setup complete"

# === Help ===

help:
	@echo "LoginDemo Build Commands"
	@echo "========================"
	@echo ""
	@echo "iOS:"
	@echo "  make ios-build    - Build iOS debug"
	@echo "  make ios-test     - Run iOS tests"
	@echo "  make ios-clean    - Clean iOS build"
	@echo "  make ios-release  - Build iOS release"
	@echo ""
	@echo "Android:"
	@echo "  make android-build   - Build Android debug"
	@echo "  make android-test    - Run Android tests"
	@echo "  make android-clean   - Clean Android build"
	@echo "  make android-release - Build Android release"
	@echo "  make android-lint    - Run Android lint"
	@echo ""
	@echo "Both Platforms:"
	@echo "  make build    - Build both platforms"
	@echo "  make test     - Test both platforms"
	@echo "  make clean    - Clean both platforms"
	@echo "  make release  - Release build both"
	@echo ""
	@echo "Setup:"
	@echo "  make setup    - Check development environment"
	@echo "  make help     - Show this help"
