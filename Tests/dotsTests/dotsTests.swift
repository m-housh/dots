import XCTest
import CliMiddlewareLive
import Dependencies
import FileClient
import dots

final class dotsTests: XCTestCase {
  func testExample() throws {
    XCTAssert(true)
  }
  
  func test_fileClient() async throws {
    let liveClient = FileClient.liveValue
    let mockClient = FileClient.mock(
      configDirectory: liveClient.configDirectory(),
      dotFilesDirectory: liveClient.dotfilesDirectory(),
      homeDirectory: liveClient.homeDirectory()
    )
    
    try await withDependencies {
      $0.fileClient = mockClient
      $0.cliMiddleware = .liveValue
      $0.logger.logLevel = .debug
      $0.globals = .init(dryRun: false)
    } operation: {
      @Dependency(\.fileClient) var fileClient: FileClient
      @Dependency(\.cliMiddleware) var cliMiddleware: CliMiddleware
      
      try await cliMiddleware.zsh(.init(context: .install))
      
      let hasConfig = try await fileClient.exists(
        fileClient.configDirectory().appendingPathComponent("zsh")
      )
      XCTAssertTrue(hasConfig)
      
      let hasZshenv = try await fileClient.exists(
        fileClient.homeDirectory().appendingPathComponent(".zshenv")
      )
      XCTAssertTrue(hasZshenv)
    }
    
  }
}

extension FileClient {
  
  static func mock(configDirectory: URL, dotFilesDirectory: URL, homeDirectory: URL) -> FileClient {
    @Dependency(\.logger) var logger
    var data: [String: DataType] = [:]
    
    enum DataType {
      case directory
      case link(String)
      case data(Data)
    }
    
    return FileClient(
      configDirectory: { configDirectory },
      createDirectory: { url,_ in
        data[url.absoluteString] = .directory
      },
      createSymlink: { source, destination in
        logger.debug("Creating symlink.")
        logger.debug("\(destination.absoluteString) -> \(source.absoluteString)")
        data[destination.absoluteString] = .link(source.absoluteString)
      },
      dotfilesDirectory: { dotFilesDirectory },
      homeDirectory: { homeDirectory },
      exists: { url in
        return data[url.absoluteString] != nil
      },
      readFile: { source in
        if let dataOrLink = data[source.absoluteString] {
          switch dataOrLink {
          case let .link(link):
            if let hasLink = data[link],
               case let .data(linkData) = hasLink {
              return linkData
            }
            break
          case let .data(data):
            return data
          case .directory:
            break
          }
        }
        return Data()
      },
      moveToTrash: { url in
        data.removeValue(forKey: url.absoluteString)
      },
       writeFile: { fileData, file in
         data[file.absoluteString] = .data(fileData)
       }
    )
  }
}
