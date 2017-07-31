
import Foundation

class TextEntryUtils {
    
    //MARK: - Helpers
    class func trimmedStringToMaxLength(sourceString: String, length: Int) -> String {
        
        var trimmedString = sourceString
        
        if sourceString.characters.count > length {
            
            trimmedString = sourceString.substringToIndex(sourceString.startIndex.advancedBy(length))
        }
        
        return trimmedString
    }
    
    
}

extension Double {
    
    func formattedStringUsingCurrencyCode(currencyCode: String) -> String? {
        
        var formattedValue: String?
        
        let numberFormatter = NSNumberFormatter()
        
        numberFormatter.currencyCode = currencyCode
        numberFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        formattedValue = numberFormatter.stringFromNumber(self)
        
        return formattedValue
    }
}