import Testing
@testable import AgentMLX

// MARK: - Mock Agentable

/// A lightweight mock that satisfies `Agentable` without touching the MLX stack.
/// Responses are deterministic ("Echo: <prompt>") and all state is inspectable.
final class MockAgent: Agentable {

    // History stored inside the actor; exposed via a separate snapshot accessor
    // because `Agentable.history` must be `nonisolated`.
    private var _history: [ChatMessage] = []

    // Protocol requirement — returns a copy safe to read from outside the actor.
    // Swift 6 requires nonisolated stored properties, so we use a nonisolated
    // computed property that always returns the empty default; tests use
    // `historySnapshot` to inspect state.
    nonisolated var history: [any ChatMessageable] { [] }

    var historySnapshot: [ChatMessage] { _history }

    var shouldThrow: Bool = false
    var generateCallCount: Int = 0

    static func create(modelSource: ModelSource) async throws -> MockAgent {
        MockAgent()
    }

    func generate(with promt: String) async throws -> String {
        generateCallCount += 1
        guard !shouldThrow else {
            throw AgentError.noChatSession
        }
        let response = "Echo: \(promt)"
        _history.append(ChatMessage(role: .user, content: promt))
        _history.append(ChatMessage(role: .assistant, content: response))
        return response
    }

    // Helper used by tests to flip the error flag from async context
    func set(shouldThrow value: Bool) {
        shouldThrow = value
    }
}

// MARK: - MockAgent – generate tests

@Suite("MockAgent – generate")
struct MockAgentGenerateTests {

    @Test("Returns echoed response")
    func returnsEchoedResponse() async throws {
        let agent = MockAgent()
        let response = try await agent.generate(with: "Hello")
        #expect(response == "Echo: Hello")
    }

    @Test("Increments call count on each call")
    func incrementsCallCount() async throws {
        let agent = MockAgent()
        _ = try await agent.generate(with: "first")
        _ = try await agent.generate(with: "second")
        let count = agent.generateCallCount
        #expect(count == 2)
    }

    @Test("Appends user then assistant message to history")
    func appendsHistoryPair() async throws {
        let agent = MockAgent()
        _ = try await agent.generate(with: "Hi")
        let history = agent.historySnapshot
        #expect(history.count == 2)
        #expect(history[0].role == .user)
        #expect(history[0].content == "Hi")
        #expect(history[1].role == .assistant)
        #expect(history[1].content == "Echo: Hi")
    }

    @Test("Multiple prompts build history in order")
    func multiplePromptsOrderedHistory() async throws {
        let agent = MockAgent()
        _ = try await agent.generate(with: "one")
        _ = try await agent.generate(with: "two")
        let history = agent.historySnapshot
        #expect(history.count == 4)
        #expect(history[0].content == "one")
        #expect(history[1].content == "Echo: one")
        #expect(history[2].content == "two")
        #expect(history[3].content == "Echo: two")
    }

    @Test("Empty prompt produces echo of empty string")
    func emptyPrompt() async throws {
        let agent = MockAgent()
        let response = try await agent.generate(with: "")
        #expect(response == "Echo: ")
    }
}

// MARK: - MockAgent – error handling tests

@Suite("MockAgent – error handling")
struct MockAgentErrorTests {

    @Test("Throws AgentError.noChatSession when shouldThrow is true")
    func throwsWhenFlagSet() async throws {
        let agent = MockAgent()
        agent.set(shouldThrow: true)
        await #expect(throws: AgentError.noChatSession) {
            _ = try await agent.generate(with: "Boom")
        }
    }

    @Test("Does not append history when generate throws")
    func noHistoryOnThrow() async throws {
        let agent = MockAgent()
        agent.set(shouldThrow: true)
        _ = try? await agent.generate(with: "Boom")
        let history = agent.historySnapshot
        #expect(history.isEmpty)
    }

    @Test("Still increments call count even when throwing")
    func callCountIncreasesOnThrow() async throws {
        let agent = MockAgent()
        agent.set(shouldThrow: true)
        _ = try? await agent.generate(with: "Boom")
        let count = agent.generateCallCount
        #expect(count == 1)
    }

    @Test("Subsequent calls succeed after disabling shouldThrow")
    func succeedsAfterClearingFlag() async throws {
        let agent = MockAgent()
        agent.set(shouldThrow: true)
        _ = try? await agent.generate(with: "fail")
        agent.set(shouldThrow: false)
        let response = try await agent.generate(with: "ok")
        #expect(response == "Echo: ok")
    }
}

// MARK: - AgentError tests

@Suite("AgentError")
struct AgentErrorTests {

    @Test("noChatSession conforms to Error")
    func noChatSessionConformsToError() {
        let error: Error = AgentError.noChatSession
        #expect(error is AgentError)
    }

    @Test("noModelAvailable conforms to Error")
    func noModelAvailableConformsToError() {
        let error: Error = AgentError.noModelAvailable
        #expect(error is AgentError)
    }

    @Test("Both cases have different descriptions")
    func casesAreDifferent() {
        let a = "\(AgentError.noChatSession)"
        let b = "\(AgentError.noModelAvailable)"
        #expect(a != b)
    }

    @Test("Can be caught as AgentError specifically")
    func catchAsAgentError() async {
        func throwing() throws { throw AgentError.noChatSession }
        do {
            try throwing()
            Issue.record("Expected throw")
        } catch let e as AgentError {
            #expect(e == .noChatSession)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Can be caught as generic Error")
    func catchAsGenericError() {
        func throwing() throws { throw AgentError.noModelAvailable }
        do {
            try throwing()
            Issue.record("Expected throw")
        } catch {
            #expect(error is AgentError)
        }
    }
}
