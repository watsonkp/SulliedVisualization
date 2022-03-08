import SwiftUI
import CoreBluetooth

// A view that displays boolean data as 7 day weeks.
// Optionally offset the start of the data to correspond to calendar months.
// Optionally specify an upper limit to correspond to days in the future.
// TODO: Use foreground and background colors. Added in iOS 15?
struct CalendarView: View {
    let data: [Week]

    var body: some View {
        if !data.isEmpty {
            VStack {
                ForEach(data) { week in
                    HStack {
                        ForEach(week.days) { day in
                            if day.placeHolder {
                                Circle()
                                    .fill(.white)
                            } else {
                                ZStack {
                                    if let value = day.value {
                                        if value {
                                            Circle()
                                                .fill(.green)
                                        } else {
                                            Circle()
                                                .fill(.gray)
                                                .opacity(0.5)
                                        }
                                    }
                                    // Apparent line width varies depending on order because it extends both inwards and outwards.
                                    // Inwards can be covered by the other circle.
                                    Circle()
                                        .stroke(style: StrokeStyle(lineWidth: 5))
                                }
                            }
                        }.aspectRatio(contentMode: .fit)
                    }
                }
            }.padding()
        } else {
            ZStack {
                Text("No data")
                    .font(.headline)
                HStack {
                    ForEach(0..<7) { _ in
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 5))
                            .opacity(0.5)
                    }
                }.aspectRatio(contentMode: .fit)
            }
        }
    }

    init(data: [Bool], startDay: Int = 0, endDay: Int? = nil) {
        var weeks = [Week]()
        for index in 0..<((data.count + 6) / 7) {
            let startIndex = max(7 * index - startDay, 0)
            let endIndex = min(7 * (index + 1) - startDay, data.count)
            if let endDay = endDay {
                weeks.append(Week(data: data[startIndex..<endIndex], endDay: endDay))
            } else {
                weeks.append(Week(data: data[startIndex..<endIndex], startDay: startDay))
            }
        }
        self.data = weeks
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let fiveDays = [true, false, false, true, true]
        let sevenDays = [true, false, false, true, false, false, true]
        let thirtyoneDays = [false, true, false, true, true, false, true,
                             true, true, true, false, false, false, true,
                             false, false, true, true, true, false, true,
                             true, false, false, true, true, false, true,
                             false, false, false]
        let partialFourWeeks = [false, true, false, true, true, false, true,
                                true, true, true, false, false, false, true,
                                false, false, true, true, true, false, true,
                                true, false]
        // TODO: A partial calendar. Has an offset start day and an end day that may be a partial week or more in the future.
        CalendarView(data: sevenDays)
        CalendarView(data: [Bool]())
        CalendarView(data: fiveDays, endDay: 7)
        CalendarView(data: thirtyoneDays)
        CalendarView(data: thirtyoneDays, startDay: 2)
        CalendarView(data: partialFourWeeks, endDay: 28)
    }
}

struct Day: Identifiable {
    let dayNumber: Int
    var id: Int {
        dayNumber
    }
    let value: Bool?
    let placeHolder: Bool

    init(dayNumber: Int, value: Bool?, placeHolder: Bool = false) {
        self.dayNumber = dayNumber
        self.value = value
        self.placeHolder = placeHolder
    }
}

struct Week: Identifiable {
    let weekNumber: Int
    var id: Int {
        weekNumber
    }
    let days: [Day]

    init(weekNumber: Int, data: [Bool]) {
        self.weekNumber = weekNumber
        var days = [Day]()
        for (index, value) in data.enumerated() {
            days.append(Day(dayNumber: index, value: value))
        }
        self.days = days
    }

    init(data: ArraySlice<Bool>, endDay: Int) {
        self.weekNumber = data.startIndex / 7
        var days = [Day]()
        // Add days to week for each data value
        for (index, value) in data.enumerated() {
            days.append(Day(dayNumber: index, value: value))
        }
        // Add suffix of days in the future
        if endDay > data.endIndex && (endDay - data.startIndex) <= 7 {
            for dayNumber in data.endIndex..<endDay {
                days.append(Day(dayNumber: dayNumber, value: nil, placeHolder: false))
            }
        }
        // Add placeholder days to reach a 7 day week
        for dayNumber in data.endIndex..<(data.endIndex + 7 - days.count) {
            days.append(Day(dayNumber: dayNumber, value: false, placeHolder: true))
        }
        self.days = days
    }

    init(data: ArraySlice<Bool>, startDay: Int = 0) {
        self.weekNumber = (startDay + data.startIndex) / 7
        var days = [Day]()
        // Prefix week with placeholder days to offset for non-zero start day
        if startDay > data.startIndex && startDay < data.endIndex {
            for dayNumber in 0..<startDay {
                days.append(Day(dayNumber: dayNumber, value: nil, placeHolder: true))
            }
        }
        // Add days to week for each data value
        for (index, value) in data.enumerated() {
            days.append(Day(dayNumber: index + startDay, value: value))
        }
        // Add placeholder days to reach a 7 day week
        for dayNumber in data.endIndex..<(data.endIndex + 7 - days.count) {
            days.append(Day(dayNumber: dayNumber + startDay, value: false, placeHolder: true))
        }
        self.days = days
    }
}
