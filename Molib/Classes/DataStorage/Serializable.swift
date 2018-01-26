import Foundation

public protocol JSONSerializable {
    func toJSONString() -> String?
    static func fromJSONString(jsonString: String) -> Self?
}

extension Storable where Self: JSONSerializable {

    func toJSONString() -> String? {

        let dictionary = toDictionary()
        let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString
    }

    func fromJSONString<T: Storable>(jsonString: String) -> T? {

        guard let jsonData = jsonString.data(using: .utf8) else { return nil }

        let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)

        guard let dictionary = jsonDictionary as? StorableDictionary else {
            return nil
        }

        return T(dictionary: dictionary)
    }
}

extension Array: JSONSerializable {

    public func toJSONString() -> String? {

        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }

        let jsonString = String(data: jsonData, encoding: .utf8)

        return jsonString
    }

    static public func fromJSONString(jsonString: String) -> Array? {

        guard let data = jsonString.data(using: .utf8),
            let array = try? JSONDecoder().decode(Array.self, from: data) else {
            return nil
        }

        return array
    }
}

