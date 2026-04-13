//
//  Agentable.swift
//  AgentMLX
//
//  Created by Volodymyr Matiukh on 12.04.2026.
//

import Foundation

public protocol Agentable {
    var history: [ChatMessageable] { get }
    static func create(modelSource: ModelSource) async throws -> Self
    func generate(with promt: String) async throws -> String
}
