import Dependencies
import Foundation
@_exported import Logging
import LoggingFormatAndPipe

extension Logger: DependencyKey {
  
  fileprivate static func factory(label: String) -> Self {
    Logger(label: "dots") { _ in
      LoggingFormatAndPipe.Handler(
        formatter: BasicFormatter([.message]),
        pipe: LoggerTextOutputStreamPipe.standardOutput
      )
    }
  }
  
  public static var liveValue: Logger {
    factory(label: "dots")
  }
  
  public static var testValue: Logger {
    factory(label: "dots-test")
  }
  
}

extension DependencyValues {
  public var logger: Logger {
    get { self[Logger.self] }
    set { self[Logger.self] = newValue }
  }
}
