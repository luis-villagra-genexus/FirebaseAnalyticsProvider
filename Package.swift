// swift-tools-version: 5.9
import PackageDescription

let GX_FC_LAST_VERSION = Version("4.2.0-beta")

let package = Package(
	name: "FirebaseProviders",
	platforms: [.iOS(.v15), .tvOS("18.0"), .watchOS(.v10), .visionOS("2.0")],
	products: [
		.library(name: "FirebaseAnalyticsProvider", targets: ["FirebaseAnalyticsProvider"]),
		.library(name: "FirebaseCrashlyticsProvider", targets: ["FirebaseCrashlyticsProvider"]),
		.library(name: "FirebaseRemoteConfigurationProivder", targets: ["FirebaseRemoteConfigurationProvider"])
	],
	dependencies: [
		.package(url: "https://github.com/GeneXus-SwiftPackages/GXCoreBL.git", .upToNextMajor(from: GX_FC_LAST_VERSION)),
		.package(url: "https://github.com/GeneXus-SwiftPackages/GXCoreModule_Common_Analytics.git", .upToNextMajor(from: GX_FC_LAST_VERSION)),
		.package(url: "https://github.com/GeneXus-SwiftPackages/GXCoreModule_SD_RemoteConfig.git", .upToNextMajor(from: GX_FC_LAST_VERSION)),
		.package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "12.3.0"))
	],
	targets: [
		.target(name: "FirebaseAnalyticsProvider",
				dependencies: [
					.product(name: "GXCoreModule_Common_Analytics", package: "GXCoreModule_Common_Analytics"),
					.product(name: "FirebaseAnalytics", package: "firebase-ios-sdk",  condition: .when(platforms: [.iOS, .tvOS])),
				],
				path: "Sources/AnalyticsProivder"),
		.target(name: "FirebaseCrashlyticsProvider",
				dependencies: [
					.product(name: "GXCoreBL", package: "GXCoreBL"),
					.product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
				],
				path: "Sources/CrashlyticsProvider"),
		.target(name: "FirebaseRemoteConfigurationProvider",
				dependencies: [
					.product(name: "GXCoreModule_SD_RemoteConfig", package: "GXCoreModule_SD_RemoteConfig"),
					.product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk")
				],
				path: "Sources/RemoteConfigurationProvider")
	]
)
