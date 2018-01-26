import Foundation

extension TimeInterval {

    public enum Intervals {

        public static let secondsInAMinute: Double = 60
        public static let secondsInAnHour: Double = 3600
        public static let secondsInADay: Double = 86400
    }

    public func secondsToHoursMinutesSeconds() -> (Int, Int, Int) {

        let time = self
        return (Int(time / Intervals.secondsInAnHour),
                Int((time.truncatingRemainder(dividingBy: Intervals.secondsInAnHour)) / Intervals.secondsInAMinute), Int((time.truncatingRemainder(dividingBy: Intervals.secondsInAnHour)).truncatingRemainder(dividingBy: Intervals.secondsInAMinute)))
    }

    public func durationInMinsAndSecondsString() -> String {

        var durationString = ""

        let (_, minutes, seconds) = secondsToHoursMinutesSeconds()

        if 0...9 ~= seconds {

            durationString = "\(minutes):0\(seconds)"

        } else {

            durationString = "\(minutes):\(seconds)"
        }

        return durationString
    }
}
