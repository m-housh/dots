import FileClient
import Foundation

extension FileClient {
  
  func ensureConfigDirectory() async throws {
    try await createDirectory(at: configDirectory())
  }
}
