import Foundation

extension Date {

    public func dateAddingDays(numberOfDays: Int) -> Date {
        let timeIntervalForDays = 86400 * numberOfDays
        return self.addingTimeInterval(Double(timeIntervalForDays))
    }
}
