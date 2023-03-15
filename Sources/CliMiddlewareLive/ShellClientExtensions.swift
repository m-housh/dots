import Dependencies
import FileClient
import Foundation
import ShellClient

extension ShellClient {
  
  func runInDotfilesDirectory(_ arguments: String...) throws {
    try self.runInDotfilesDirectory(arguments)
  }
  
  func runInDotfilesDirectory(_ arguments: [String]) throws {
    @Dependency(\.fileClient) var fileClient: FileClient
    
    FileManager.default
      .changeCurrentDirectoryPath(fileClient.dotfilesDirectory().absoluteString)
    
    try self.foreground(.init(arguments))
  }
}
