import Dependencies
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension FileClient: DependencyKey {
  
  public static var liveValue: FileClient {
    .live(environment: ProcessInfo.processInfo.environment)
  }
  
  public static func live(environment: [String: String] = [:]) -> Self {
    let environment = Environment(environment: environment)
    return .init(
      configDirectory: {
        guard let xdgConfigHome = environment.xdgConfigHome,
              let configUrl = URL(string: xdgConfigHome)
        else {
          return FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config")
        }
        return configUrl
      },
      createDirectory: { url, withIntermediates in
        try FileManager.default.createDirectory(
          at: url,
          withIntermediateDirectories: withIntermediates
        )
      },
      createSymlink: { source, destination in
        try FileManager.default.createSymbolicLink(
          at: source,
          withDestinationURL: destination
        )
      },
      dotfilesDirectory: {
        guard let dotfiles = environment.dotfilesDirectory,
              let dotfilesUrl = URL(string: dotfiles)
        else {
          return FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".dotfiles")
        }
        return dotfilesUrl
      },
      homeDirectory: {
        FileManager.default.homeDirectoryForCurrentUser
      },
      exists: { path in
        FileManager.default.fileExists(atPath: path.absoluteString)
      },
      readFile: { path in
        try Data(contentsOf: path)
      },
      moveToTrash: { path in
        try FileManager.default.trashItem(at: path, resultingItemURL: nil)
      },
      writeFile: { data, path in
        try data.write(to: path)
      }
    )
  }
}

fileprivate struct Environment {
  let xdgConfigHome: String?
  let dotfilesDirectory: String?
  
  enum CodingKeys: String, CodingKey {
    case xdgConfigHome = "XDG_CONFIG_HOME"
    case dotfilesDirectory = "DOTFILES"
  }
  
  init(environment: [String: String]) {
    self.xdgConfigHome = environment[CodingKeys.xdgConfigHome.rawValue]
    self.dotfilesDirectory = environment[CodingKeys.dotfilesDirectory.rawValue]
  }
}
