//
//  ConfigurationService.swift
//  CoronaContact
//

import Foundation
import Resolver

class ConfigurationService {
    private(set) var currentConfig: Configuration!
    @Injected private var networkService: NetworkService
    let log = ContextLogger(context: .application)

    private struct ConfigWrapper: Codable {
        var configuration: Configuration
    }

    init() {
        if !loadConfig(shipped: false) {
            loadConfig(shipped: true)
        }
    }

    func update() {
        networkService.fetchConfiguration { [weak self] result in
            switch result {
            case let .success(data):
                self?.saveToDisk(data)
            case let .failure(error):
                self?.log.error("error updating config: \(error)")
                return
            }
        }
    }

    private func parseConfig(data: Data) throws {
        let jsonDecoder = JSONDecoder()
        let wrapper = try jsonDecoder.decode(ConfigWrapper.self, from: data)
        currentConfig = wrapper.configuration
    }

    @discardableResult
    private func loadConfig(shipped: Bool = false) -> Bool {
        var fileURL = cacheFileURL()
        if shipped { fileURL = Bundle.main.url(forResource: "configuration", withExtension: "json")! }
        // print("loading", shipped ? "config from bundle" : "config from cache")
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            log.error("config file not found")
            return false
        }
        do {
            let jsonData = try Data(contentsOf: fileURL)
            try parseConfig(data: jsonData)
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    private func saveToDisk(_ data: Data) {
        do {
            try data.write(to: cacheFileURL(), options: .atomicWrite)
            try parseConfig(data: data)
        } catch {
            log.error("error caching config \(error)")
        }
    }

    private func cacheFileURL() -> URL {
        let folderURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return folderURLs[0].appendingPathComponent("config.cache")
    }
}
