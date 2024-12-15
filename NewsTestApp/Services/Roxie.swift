//
//  Roxie.swift
//  JoySpring
//
//  Created by Vlad Sys on 15.09.24.
//

import Foundation

open class NonCreatable {
// MARK: - Construction

    private init() {
        // Do nothing
    }
}

// ----------------------------------------------------------------------------

public final class Roxie: NonCreatable {
    /// Returns the documents directory for the current user.
    public static var documentsDirectory: URL? {
        return Directories.Documents
    }

// MARK: - Constants

    private struct Directories {
        /// The documents directory for the current user.
        static let Documents: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

// MARK: - Methods

    /// Returns the name of static type of the subject being reflected.
    public static func typeName(of subject: Any) -> String {
        return Reflection(of: subject).type.name
    }

    /// Checks if the application is running unit tests.
    public static var isRunningXCTest: Bool {
        // How to let the app know if its running Unit tests in a pure Swift project?
        // @link https://stackoverflow.com/a/29991529
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}

// ----------------------------------------------------------------------------

public struct Reflection {
// MARK: - Construction

    public init(of subject: Any) {
        // Get type of subject
        let type = (subject is Any.Type) ? subject : Swift.type(of: subject)

        // Init instance
        self.subject = subject
        self.type = Reflection.metatypeNameParser.reflect(type as! Any.Type)
    }

// MARK: - Properties

    public let subject: Any

    public let type: ReflectedType

// MARK: - Constants

    private static let metatypeNameParser: MetatypeNameParser = MetatypeNameParser()
}

// ----------------------------------------------------------------------------

public struct ReflectedType {
// MARK: - Construction

    internal init(name: String, fullName: String, isOptional: Bool, isImplicitlyUnwrappedOptional: Bool, isProtocol: Bool) {
        // Init instance
        self.name = name
        self.fullName = fullName
        self.isOptional = isOptional
        self.isImplicitlyUnwrappedOptional = isImplicitlyUnwrappedOptional
        self.isProtocol = isProtocol
    }

// MARK: - Properties

    public let name: String

    public let fullName: String

    public let isOptional: Bool

    public let isImplicitlyUnwrappedOptional: Bool

    public let isProtocol: Bool
}

class MetatypeNameParser {
// MARK: - Methods

    func reflect(_ type: Any.Type) -> ReflectedType {
        let root = split(fullName: String(reflecting: type), maxDepth: 1)
        var node = root

        let isOptional = self.isOptional(root)
        let isImplicitlyUnwrappedOptional = self.isImplicitlyUnwrappedOptional(root)

        if (isOptional || isImplicitlyUnwrappedOptional) {
            if let child = root.child {
                node = child
            }
        }

        let (simpleName, canonicalName) = normalizeName(node)
        return ReflectedType(
            name: simpleName,
            fullName: canonicalName,
            isOptional: isOptional,
            isImplicitlyUnwrappedOptional: isImplicitlyUnwrappedOptional,
            isProtocol: isProtocol(node)
        )
    }

// MARK: - Private Methods

    private func split(fullName: String, maxDepth: UInt = UInt.max) -> MetatypeNode {
        var wrappedName = Substring(fullName)
        var names = [String]()

        // Split names of Types
        for _ in 0..<maxDepth {
            if let from = wrappedName.firstIndex(of: "<"), let upto = wrappedName.firstIndex(of: ">") {

                // Extract name of wrapped type
                names.append("\(wrappedName[...from])T\(wrappedName[upto...])")
                wrappedName = wrappedName[wrappedName.index(after: from)..<upto]
            } else {
                break
            }
        }

        // Build linked list of MetatypeNodes
        var node = MetatypeNode(value: String(wrappedName), child: nil)
        for name in names.reversed() {
            node = MetatypeNode(value: name, child: node)
        }

        // Done
        return node
    }

    private func isOptional(_ node: MetatypeNode) -> Bool {
        return Inner.Prefixes.Optionals.contains { node.value.hasPrefix($0) }
    }

    private func isImplicitlyUnwrappedOptional(_ node: MetatypeNode) -> Bool {
        return Inner.Prefixes.ImplicitlyUnwrappedOptionals.contains { node.value.hasPrefix($0) }
    }

    private func isProtocol(_ node: MetatypeNode) -> Bool {
        return Inner.Suffixes.Protocols.contains { node.value.hasSuffix($0) }
    }

    private func normalizeName(_ node: MetatypeNode) -> (simpleName: String, canonicalName: String) {
        // Build canonical name of Type
        var canonicalName = ""
        Swift.sequence(first: node, next: { $0.child }).reversed().forEach {
            let value = normalize(name: $0.value)

            if (canonicalName.isEmpty) {
                canonicalName = value
            } else if let range = value.range(of: "<T>") {
                canonicalName = value.replacingCharacters(in: range, with: "<\(canonicalName)>")
            } else {
                debugPrint("Invalid state. Value ‘\(value)’ does not contains placeholder ‘<T>’.")
            }
        }

        // Extract simple name of Type
        var startIndex = canonicalName.startIndex
        var char: Character = "?" // dummy

        for index in canonicalName.indices {
            char = canonicalName[index]

            if char == "." {
                startIndex = canonicalName.index(after: index)
            } else if char == "<" {
                break
            }
        }

        // Done
        return (String(canonicalName[startIndex...]), canonicalName)
    }

    private func normalize(name: String) -> String {
        return name
    }

// MARK: - Constants

    private struct Inner {
        struct Prefixes {
            static let ImplicitlyUnwrappedOptionals = ["Swift.ImplicitlyUnwrappedOptionals<", "ImplicitlyUnwrappedOptionals<"]
            static let Optionals = ["Swift.Optional<", "Optional<"]
        }

        struct Suffixes {
            static let Protocols = [".Protocol"]
        }
    }
}

// ----------------------------------------------------------------------------

class MetatypeNode {
// MARK: - Construction

    init(value: String, child: MetatypeNode? = nil) {
        // Init instance
        self.value = value
        self.child = child
    }

// MARK: - Properties

    let value: String

    let child: MetatypeNode?
}
