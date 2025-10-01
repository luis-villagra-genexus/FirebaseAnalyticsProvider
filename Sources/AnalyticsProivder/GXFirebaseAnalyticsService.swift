//
//  GXFirebaseAnalyticsService.swift
//

import GXCoreBL
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
import FirebaseCore
#endif

@objc(GXFirebaseAnalyticsService)
public class GXFirebaseAnalyticsService: NSObject {
	
	// MARK: - Singleton
	
	public static let sharedInstance = GXFirebaseAnalyticsService()
	
	private override init() {
		super.init()
	}
	
	// MARK: Private Helpers
	
#if canImport(FirebaseAnalytics)
	private struct Constants {
		static let eventNameMaxLength = 40
	}
	
	private func eventNameByReplacingInvalidCharacters(eventName: String) -> String {
		var result = eventName.replacingOccurrences(of: ".", with: "_")
		
		let validChars = NSMutableCharacterSet.alphanumeric()
		validChars.addCharacters(in: "_")
		
		let unwantedCharacters = validChars.inverted
		
		let validCharsComponents = result.components(separatedBy: unwantedCharacters)
		if validCharsComponents.count > 1 {
			result = validCharsComponents.joined(separator: "")
		}
		if result.count > Constants.eventNameMaxLength {
			result = String(result.suffix(Constants.eventNameMaxLength))
		}
		if result.starts(with: "_") {
			result = String(result.dropFirst())
		}
		if let firstChar = result.first, !firstChar.isLetter {
			result = String("A" + result.dropFirst())
		}
		return result
	}
#else
	private func logFirebaseAnalyticsUnsupported() {
		guard GXLog.isLogEnabled() else {
			return
		}
		GXFoundationServices.loggerService()?.logMessage("Firebase Analytics is unavailable in \(GXClientInformation.osName())", for: .general, with: .debug, logToConsole: false)
	}
#endif
}

extension GXFirebaseAnalyticsService: GXAnalyticsService {
	
	public func trackView(_ name: String) {
#if canImport(FirebaseAnalytics)
		Analytics.logEvent(AnalyticsEventScreenView, parameters: [
			AnalyticsParameterScreenName: name,
			AnalyticsParameterScreenClass: "gx_view"
		])
#else
		self.logFirebaseAnalyticsUnsupported()
#endif
	}
	
	public func trackView(from object: GXSDObjectLocator) {
		GXAnalyticsServiceHelper.defaultAnalyticsService(self, trackViewFromObject: object)
	}
	
	public func trackEventName(_ name: String, category: String, label: String?, value: NSNumber?, customParameters: [String : String]?) {
#if canImport(FirebaseAnalytics)
		let eventName = eventNameByReplacingInvalidCharacters(eventName: name)
		guard !eventName.isEmpty else {
			return
		}
		
		var parameters: [String : Any] = [
			"gx_category": category as NSObject,
			"gx_label": (label ?? "") as NSObject,
			"gx_value": value ?? NSNumber(value: 0) as NSObject
		]
		
		if let customParameters {
			parameters.merge(customParameters) { (_, second) in second }
		}
        
        // Send the special "items" item as an array of dictionaries instead of a string
		// Ref: https://firebase.google.com/docs/reference/kotlin/com/google/firebase/analytics/FirebaseAnalytics.Param#ITEMS()
        if let itemsString = parameters[AnalyticsParameterItems] as? String,
           let itemsData = itemsString.data(using: .utf8),
           let itemsDict = try? JSONSerialization.jsonObject(with: itemsData, options: []) as? [[String: Any]] {
            parameters[AnalyticsParameterItems] = itemsDict
        }
		
		Analytics.logEvent(eventName, parameters: parameters)
#else
		self.logFirebaseAnalyticsUnsupported()
#endif
	}
	
	public func trackEventName(_ name: String, from object: GXSDObjectLocator, sender: Any?) {
#if canImport(FirebaseAnalytics)
		GXAnalyticsServiceHelper.defaultAnalyticsService(self, trackEventName: name, from: object, sender: sender)
#else
		self.logFirebaseAnalyticsUnsupported()
#endif
	}
	
	public func setUserId(_ userId: String) {
#if canImport(FirebaseAnalytics)
		Analytics.setUserID(userId)
#else
		self.logFirebaseAnalyticsUnsupported()
#endif
	}
	
	public func setCommerceTrackerId(_ trackerId: String) {
#if canImport(FirebaseAnalytics)
		guard GXLog.isLogEnabled() else {
			return
		}
		GXFoundationServices.loggerService()?.logMessage("Firebase Analytics setCommerceTrackerId is not supported.", for: .general, with: .debug, logToConsole: false)
#else
		self.logFirebaseAnalyticsUnsupported()
#endif
	}
	
	public func trackPurchaseId(_ purchaseId: String, affiliation: String, revenue: NSNumber, tax: NSNumber, shipping: NSNumber, currencyCode: String) {
#if canImport(FirebaseAnalytics)
		Analytics.logEvent(AnalyticsEventPurchase, parameters: [
			AnalyticsParameterTransactionID: purchaseId,
			AnalyticsParameterAffiliation: affiliation,
			AnalyticsParameterValue: revenue,
			AnalyticsParameterTax: tax,
			AnalyticsParameterShipping: shipping,
			AnalyticsParameterCurrency: currencyCode
		])
#else
		self.logFirebaseAnalyticsUnsupported()
#endif
	}
	
	public func trackPurchasedItem(_ productId: String, purchaseId: String, name: String, category: String, price: NSNumber, quantity: NSNumber, currencyCode: String) {
#if canImport(FirebaseAnalytics)
		Analytics.logEvent(AnalyticsEventAddToCart, parameters: [
			AnalyticsParameterItemID: productId,
			AnalyticsParameterTransactionID: purchaseId,
			AnalyticsParameterItemName: name,
			AnalyticsParameterItemCategory: category,
			AnalyticsParameterPrice: price,
			AnalyticsParameterQuantity: quantity,
			AnalyticsParameterCurrency: currencyCode
		])
#else
		self.logFirebaseAnalyticsUnsupported()
#endif
	}
}
