import Foundation


public protocol UserDefaultsKeyProtocol {
	var key: String { get }
}

public protocol UserDefaultWrapperProtocol {
	associatedtype DataType
	var key: UserDefaultsKeyProtocol { set get }
	var defaultValue: DataType { get set }
	var userDefaults: UserDefaultsService { get set }
}

private protocol AnyOptional {
	var isNil: Bool { get }
}

extension Optional: AnyOptional {
	var isNil: Bool { self == nil }
}

@propertyWrapper
public struct UserDefault<Value>: UserDefaultWrapperProtocol {
	
	public var key: UserDefaultsKeyProtocol
	public var defaultValue: Value
	public var userDefaults: UserDefaultsService

	public var wrappedValue: DataType {
		get {
			return userDefaults.object(forKey: key) as? DataType ?? defaultValue
		}
		set {
			if let optional = newValue as? AnyOptional, optional.isNil {
				userDefaults.remove(forKey: key)
			} else {
				userDefaults.set(newValue, forKey: key)
			}
		}
	}
	
	public init(
		key: UserDefaultsKeyProtocol,
		defaultValue: Value,
		userDefaults: UserDefaultsService = UserDefaultsService.shared
	) {
		self.key = key
		self.defaultValue = defaultValue
		self.userDefaults = userDefaults
	}
}


	//public class UserDefaultsService {
	//	public static var shared: UserDefaultsAccessor
	//}

public class UserDefaultsService {
	
	var userDefault: UserDefaults
	var suitName: String?
	
	public static private(set) var shared: UserDefaultsService = UserDefaultsService(suiteName: nil)
	
	public init(suiteName: String?) {
		self.suitName = suiteName
		self.userDefault = UserDefaults(suiteName: suiteName)!
	}
	
	public static func instantiate(withSuiteName suiteName: String?) {
		UserDefaultsService.shared = UserDefaultsService(suiteName: suiteName)
	}
	
		//Setter:-
	public func set(_ value: Any, forKey key: UserDefaultsKeyProtocol) {
		self.userDefault.set(value, forKey: key.key)
	}
	
	
		//Getter:-
	public func object(forKey key: UserDefaultsKeyProtocol) -> Any? {
		return self.userDefault.object(forKey: key.key)
	}
	
	public func int(forKey key: UserDefaultsKeyProtocol) -> Int {
		return self.userDefault.integer(forKey: key.key)
	}
	
	public func bool(forKey key: UserDefaultsKeyProtocol) -> Bool {
		return self.userDefault.bool(forKey: key.key)
	}
	
		//Remove
	public func remove(forKey key: UserDefaultsKeyProtocol) {
		self.userDefault.removeObject(forKey: key.key)
	}
	
	public func removeAll() {
		
		switch suitName {
			case .some(let value):
				self.userDefault.removePersistentDomain(forName: value)
			case .none:
				UserDefaults.resetStandardUserDefaults()
		}
	}
	
}
