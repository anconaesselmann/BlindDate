//  Created by Axel Ancona Esselmann on 12/28/20.
//  Copyright © 2020 Axel Ancona Esselmann. All rights reserved.
//

import Foundation

extension Date {
    static var secondsInAMinute: Double { 60 }

    static var secondsInAnHour: Double { secondsInAMinute * 60 }

    static var secondsInADay: Double { secondsInAnHour * 24 }

    public static var now: Date { Date() }
}

public extension Array where Element == Date {
    var timeDeltas: [TimeInterval] {
        return neighbors.map { $1.timeIntervalSince($0) }
    }

    var totalTime: TimeInterval {
        return timeDeltas.reduce(0, +)
    }
}

public extension Date {

    func rounded(on amount: Int, _ component: Calendar.Component) -> Date {
        let cal = Calendar.current
        let value = cal.component(component, from: self)

        // Compute nearest multiple of amount:
        let roundedValue = lrint(Double(value) / Double(amount)) * amount
        let newDate = cal.date(byAdding: component, value: roundedValue - value, to: self)!

        return newDate.floorAllComponents(before: component)
    }

    func floorAllComponents(before component: Calendar.Component) -> Date {
        // All components to round ordered by length
        let components = [Calendar.Component.year, .month, .day, .hour, .minute, .second, .nanosecond]

        guard let index = components.firstIndex(of: component) else {
            fatalError("Wrong component")
        }

        let cal = Calendar.current
        var date = self

        components.suffix(from: index + 1).forEach { roundComponent in
            let value = cal.component(roundComponent, from: date) * -1
            date = cal.date(byAdding: roundComponent, value: value, to: date)!
        }

        return date
    }

    static var LocaleWantsAMPM : Bool{
        return DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:NSLocale.current)!.contains("a")
    }

}

extension Date {
    public func subtracting(seconds: TimeInterval) -> Date {
        self.addingTimeInterval(-seconds)
    }

    public func adding(seconds: TimeInterval) -> Date {
        self.addingTimeInterval(seconds)
    }

    public func seconds(from date: Date) -> TimeInterval {
        return self.distance(to: date)
    }
}

extension Date {

    enum FormatComponents: String {
        // YEAR
        case y    //  2008    Year, no padding
        case yy   //    08    Year, two digits (padding with a zero if necessary)
        case yyyy //  2008    Year, minimum of four digits (padding with zeros if necessary)

        // QUARTER
        case Q    //     4    The quarter of the year. Use QQ if you want zero padding.
        case QQ
        case QQQ  //    Q4    Quarter including "Q"
        case QQQQ //   4th quarter    Quarter spelled out

        // MONTH
        case M     //  12    The numeric month of the year. A single M will use '1' for January.
        case MM    //  12    The numeric month of the year. A double M will use '01' for January.
        case MMM   // Dec    The shorthand name of the month
        case MMMM  // December Full name of the month
        case MMMMM // D       Narrow name of the month

        // DAY
        case d    // 14    The day of the month. A single d will use 1 for January 1st.
        case dd   //  14    The day of the month. A double d will use 01 for January 1st.
        case F    // 3rd Tuesday in December    The day of week in the month
        case E    // Tue    The abbreviation for the day of the week
        case EEEE    // Tuesday    The wide name of the day of the week
        case EEEEE    // T    The narrow day of week
        case EEEEEE   //  Tu    The short day of week

        // HOUR
        case h   // 4    The 12-hour hour.
        case hh  //  04    The 12-hour hour padding with a zero if there is only 1 digit
        case H   // 16    The 24-hour hour.
        case HH  //  16    The 24-hour hour padding with a zero if there is only 1 digit.
        case a   // PM    AM / PM for 12-hour time formats

        // MINUTE
        case m    // 35    The minute, with no padding for zeroes.
        case mm   // 35    The minute with zero padding.

        // SECOND
        case s    // 8    The seconds, with no padding for zeroes.
        case ss   // 08    The seconds with zero padding.
        case SSS  //  1234    The milliseconds.

        // TIME ZONE
        case zzz    // CST    The 3 letter name of the time zone. Falls back to GMT-08:00 (hour offset) if the name is not known.
        case zzzz   //  Central Standard Time    The expanded time zone name, falls back to GMT-08:00 (hour offset) if name is not known.
        case ZZZZ   //  CST-06:00    Time zone with abbreviation and offset
        case Z    // -0600    RFC 822 GMT format. Can also match a literal Z for Zulu (UTC) time.
        case ZZZZZ   //  -06:00    ISO 8601 time zone format

        // Format
        case colon = ":"
        case space = " "
        case comma = ","
    }
    func formated(_ formatComponents: FormatComponents...) -> String {
        let dateFormatter = DateFormatter()
        let template = formatComponents.map { $0.rawValue }.joined()
        dateFormatter.setLocalizedDateFormatFromTemplate(template) // set template after setting locale
        return dateFormatter.string(from: self)
    }
}

extension DateComponents {
    func toTimeString(wantsAMPM: Bool=Date.LocaleWantsAMPM) -> String {

        let date = Calendar.current.date(bySettingHour: self.hour ?? 0, minute: self.minute ?? 0, second: 0, of: Date())!


        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = DateFormatter.Style.medium

        formatter.dateFormat = wantsAMPM ? "hh:mm a" : "HH:mm"
        return formatter.string(from: date)

    }
}

extension TimeInterval {

    func stringDaysFromTimeInterval() -> String {

        let aday = 86400.0 //in seconds
        let time = Double(self).magnitude

        let days = time / aday

        return String(format: "%.2f", days)

    }
}

extension Array {
    func closest(to date: Date, withinBefore: TimeInterval, withinAfter: TimeInterval, dateProvider: (Element) -> Date) -> Element? {
        let interval = DateInterval(start: date.subtracting(seconds: withinBefore), duration: withinBefore + withinAfter)
        let valuesInInterval = elements(within: interval, dateProvider: dateProvider)
        guard let first = valuesInInterval.first else {
            return nil
        }
        var closest = first
        var distance = abs(date.distance(to: dateProvider(first)))
        for valueInInterval in valuesInInterval {
            let newDistance = abs(date.distance(to: dateProvider(valueInInterval)))
            if newDistance < distance {
                distance = newDistance
                closest = valueInInterval
            }
        }
        return closest
    }

    func elements(within interval: DateInterval, dateProvider: (Element) -> Date) -> [Element] {
        filter { interval.contains(dateProvider($0)) }
    }
}

extension Array where Element == Date {
    func closest(to date: Date, withinBefore: TimeInterval, withinAfter: TimeInterval) -> Element? {
        let interval = DateInterval(start: date.subtracting(seconds: withinBefore), duration: withinBefore + withinAfter)
        let valuesInInterval = self[interval]
        guard let first = valuesInInterval.first else {
            return nil
        }
        var closest = first
        var distance = abs(date.distance(to: first))
        for valueInInterval in valuesInInterval {
            let newDistance = abs(date.distance(to: valueInInterval))
            if newDistance < distance {
                distance = newDistance
                closest = valueInInterval
            }
        }
        return closest
    }

    subscript(_ interval: DateInterval) -> [Element] {
        elements(within: interval)
    }

    func elements(within interval: DateInterval) -> [Element] {
        filter { interval.contains($0) }
    }
}

extension DateComponents {
    func year(_ year: Int) -> Self {
        var component = self
        component.year = year
        return component
    }

    func month(_ month: Int) -> Self {
        var component = self
        component.month = month
        return component
    }

    func day(_ day: Int) -> Self {
        var component = self
        component.day = day
        return component
    }

    func hour(_ hour: Int) -> Self {
        var component = self
        component.hour = hour
        return component
    }

    func minute(_ minute: Int) -> Self {
        var component = self
        component.minute = minute
        return component
    }

    func second(_ second: Int) -> Self {
        var component = self
        component.second = second
        return component
    }

    func date(year: Int, month: Int, day: Int) -> Self {
        self
            .year(year)
            .month(month)
            .day(day)
    }

    func time(hour: Int = 0, minute: Int = 0, second: Int = 0) -> Self {
        self
            .hour(hour)
            .minute(minute)
            .second(second)
    }

    func date(inTimezone: TimeZone = .current) -> Date? {
        Calendar.current.date(from: self)
    }

    static func time(hour: Int = 0, minute: Int = 0, second: Int = 0) -> DateComponents {
        DateComponents().time(hour: hour, minute: minute, second: second)
    }

}

extension Date {
    func values(spacedApartBy distance: TimeInterval, totalNumber: Int) -> [Date] {
        var values: [Date] = [self]
        var last = self
        for _ in 0..<(totalNumber - 1) {
            let new = last.adding(seconds: distance)
            values.append(new)
            last = new
        }
        return values
    }
}

