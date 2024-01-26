  //
  //  File.swift
  //
  //
  //  Created by Alberto Novo Garrido on 2023-12-11.
  //

import Dependencies

extension Array where Element == MoodEntry {
  public static var mock: [MoodEntry] = [.mockGood(), .mockMeh(), .mockBad()]
}

extension MoodEntry {
  public static func mockBad() -> MoodEntry {
    @Dependency(\.uuid) var uuid
    @Dependency(\.date.now) var now
    return .init(
      id: .init(uuid()),
      date: now.advanced(by: 3600),
      colorCode: .init(red: 1, green: 0.5, blue: 0.43, opacity: 1),
      moodScale: 0.1,
      mood: .terrible,
      activities: [.work, .sleep],
      quickNote: "Terrible day",
      observations: "Terrible day",
      weatherEntry: .snowy
    )
  }
  
  public static func mockGood() -> MoodEntry {
    @Dependency(\.uuid) var uuid
    @Dependency(\.date.now) var now
    return .init(
      id: .init(uuid()),
      date: now,
      colorCode: .init(red: 0.59, green: 0.83, blue: 0.36, opacity: 1),
      moodScale: 0.7,
      mood: .good,
      activities: [.family, .exercise, .traveling],
      quickNote: "Quick note title",
      observations: "note title",
      weatherEntry: .cloudy
    )
  }
  
  public static func mockAwesome() -> MoodEntry {
    @Dependency(\.uuid) var uuid
    @Dependency(\.date.now) var now
    return .init(
      id: .init(uuid()),
      date: now,
      colorCode: .init(red: 0.59, green: 0.83, blue: 0.36, opacity: 1),
      moodScale: 1,
      mood: .awesome,
      activities: [.family, .exercise, .traveling],
      quickNote: "Quick note title",
      observations: "note title",
      weatherEntry: .cloudy
    )
  }
  
  public static func mockMeh() -> MoodEntry {
    @Dependency(\.uuid) var uuid
    @Dependency(\.date.now) var now
    return .init(
      id: .init(uuid()),
      date: now,
      colorCode: .init(red: 1, green: 0.81, blue: 0.29, opacity: 1),
      moodScale: 0.5,
      mood: .okay,
      activities: [.work, .health],
      quickNote: "Regular day",
      observations: "Regular day, gray and cloudy. Too cold to go outside",
      weatherEntry: .overcast
    )
  }
}

extension MoodEntry {
  public static var new: MoodEntry = {
    @Dependency(\.uuid) var uuid
    @Dependency(\.date.now) var now
    return .init(
      id: .init(uuid()),
      date: now,
      colorCode: .init(red: 1, green: 0.81, blue: 0.29, opacity: 1),
      moodScale: 0.5,
      mood: .okay,
      activities: [],
      quickNote: "",
      observations: ""
    )
  }()
}
