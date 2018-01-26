
import Foundation

class TextEntryUtils {
    
    //MARK: - Helpers
    class func trimmedStringToMaxLength(sourceString: String, length: Int) -> String {

        return String(sourceString.prefix(length))
    }
}

extension Double {
    
    func formattedStringUsingCurrencyCode(currencyCode: String) -> String? {
        
        var formattedValue: String?
        
        let numberFormatter = NumberFormatter()
        
        numberFormatter.currencyCode = currencyCode
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        
        formattedValue = numberFormatter.string(from: NSNumber(value: self))
        
        return formattedValue
    }
}
