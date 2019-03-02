//
//  LonaModule.swift
//  LonaStudio
//
//  Created by devin_abbott on 3/9/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

private let defaultReadmeContents = """
## Overview

This is a Lona workspace.

Here we define the components, tokens (colors, text styles, shadows, etc), and data types that make up our design system.

We then use the Lona compiler to convert this design system to platform-specific code.

> You can learn more about Lona [here](https://github.com/airbnb/Lona).
"""

class LonaModule {
    struct ComponentFile {
        let url: URL
        var name: String {
            return url.deletingPathExtension().lastPathComponent
        }
    }

    let url: URL

    init(url: URL) {
        self.url = url
    }

    var colorsFileUrls: [URL] {
        return FileSearch.search(in: url, forFilesWithSuffix: "colors.json", ignoring: ["node_modules"])
    }

    var textStyleFileUrls: [URL] {
        return FileSearch.search(in: url, forFilesWithSuffix: "textStyles.json", ignoring: ["node_modules"])
    }

    var shadowsFileUrls: [URL] {
        return FileSearch.search(in: url, forFilesWithSuffix: "shadows.json", ignoring: ["node_modules"])
    }

    var gradientsFileUrls: [URL] {
        return FileSearch.search(in: url, forFilesWithSuffix: "gradients.json", ignoring: ["node_modules"])
    }

    func componentFiles() -> [ComponentFile] {
        return LonaModule.componentFiles(in: url)
    }

    func componentFile(named name: String) -> ComponentFile? {
        return componentFiles().first(where: { arg in arg.name == name })
    }

    func component(url: URL) -> CSComponent? {
        guard let componentFile = componentFiles().first(where: { arg in arg.url == url }) else { return nil }
        return CSComponent(url: componentFile.url)
    }

    func component(named name: String) -> CSComponent? {
        guard let componentFile = componentFiles().first(where: { arg in arg.name == name }) else { return nil }
        return CSComponent(url: componentFile.url)
    }

    var types: [CSType] {
        if let types = LonaModule.cachedTypes[url] { return types }

        let files = componentFiles().sorted { a, b in a.name < b.name }

        let components = files.map { component(url: $0.url) }.compactMap { $0 }

        let types: [[CSType]] = components.map { component in
            let types: [CSType?] = component.parameters.map { param in
                switch param.type {
                case .named(let name, .variant(let contents)):
                    return .named((component.name ?? "") + "." + name, .variant(contents))
                default:
                    return nil
                }
            }

            return types.compactMap { $0 }
        }

        let flat = Array(types.joined())

        LonaModule.cachedTypes[url] = flat

        return flat
    }

    func type(named typeName: String) -> CSType? {
        for type in types {
            if case CSType.named(let name, _) = type, name == typeName {
                return type
            }
        }

        return nil
    }

    // MARK: - STATIC

    private static var cachedTypes: [URL: [CSType]] = [:]

    static var current: LonaModule {
        return LonaModule(url: CSUserPreferences.workspaceURL)
    }

    static func componentFiles(in workspace: URL) -> [ComponentFile] {
        var files: [ComponentFile] = []

        let fileManager = FileManager.default
        let keys = [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey]
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsHiddenFiles]

        guard let enumerator = fileManager.enumerator(
            at: workspace,
            includingPropertiesForKeys: keys,
            options: options,
            errorHandler: {(_, _) -> Bool in true }) else { return files }

        while let file = enumerator.nextObject() as? URL {
            if file.pathExtension == "component" {
                files.append(ComponentFile(url: file))
            }
        }

        return files
    }

    static func createWorkspace(at url: URL) throws {
        let workspaceName = url.lastPathComponent
        let workspaceParent = url.deletingLastPathComponent()

        let root = VirtualDirectory(name: workspaceName) {
            [
                VirtualFile(name: "README.md") {
                    defaultReadmeContents.data(using: .utf8)!
                },
                VirtualFile(name: "lona.json") {
                    CSData.Object([:])
                },
                VirtualDirectory(name: "assets"),
                VirtualDirectory(name: "components"),
                VirtualDirectory(name: "foundation") {
                    [
                        VirtualFile(name: "colors.json") {
                            CSData.Object(["colors": CSData.Array([])])
                        },
                        VirtualFile(name: "textStyles.json") {
                            CSData.Object(["textStyles": CSData.Array([])])
                        },
                        VirtualFile(name: "shadows.json") {
                            CSData.Object(["shadows": CSData.Array([])])
                        }
                    ]
                }
            ]
        }

        try VirtualFileSystem.write(node: root, relativeTo: workspaceParent)
    }
}
