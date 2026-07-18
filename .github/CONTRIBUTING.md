# Contributing to DNS Inspector

This document describes the guidelines for contributing to DNS Inspector. Items with the words **MUST** or **MUST NOT** are hard-requirements.

## Development Strategy

DNS Inspector follows a typical semantic version system of major, minor, and patch releases. Major releases are reserved for significant user-facing changes, minor releases may be used for significant non-user-facing changes, and patch releases are reserved for bugfixes that do not impact the behaviour of the application. Only project administrators can publish a new release of the app.

### Branching

The main branch of the app is the `app-store` branch.

Minor and patch releases can be developed and cut directly from the `app-store` branch, however major releases **MUST** be developed in a dedicated branch to ensure that minor and patch releases can occur during development, if needed.

All new releases **MUST** have an associated git tag.

### Code Style

- Swift code **MUST** adhere to the project's defined style, enforced by the SwiftLint tool.

### Testing

- Any changes or new functionality to DNSKit **MUST** be covered by an automated test

### Security

These rules are *in addition* to the security policy of the app.

- All new code **MUST** be written in a memory-safe language. The use of memory-unsafe languages like C is prohibited.

### Privacy

These rules are *in addition* to the privacy policy of the app.

- DNS Inspector **MUST** only send the DNS message to the server selected by the user. No other third-party server or service may be used for inspection.
- User-provided data, including the DNS query, **MUST NOT** appear in error logs. Such data can appear in debug logs, which are disabled by default.

## AI Generated Content

It is **expressly forbidden** to contribute to DNS Inspector any content that has been created with the assistance of large language models or other prompt-based artificial intelligence tooling. This includes tools such as, but not limited to, ChatGPT, Claude, Copilot, and Gemini.

The code, documentation, and localization that makes up DNS Inspector **MUST** be written by people. We reserve the right to selectively approve, reject or remove contributions where AI or LLM tools have been, or are suspected to have been, used, at our discretion. This policy includes user-submitted content such as but not limited to GitHub issues, pull requests, or security reports.

DNS Inspector believes that AI or LLM tools produce subpar content, introduce security risks, and most importantly rob individuals of compensation or recognition for their labour.

## Conduct

All contributors of the DNS Inspector project **MUST** follow our [Code of Conduct](https://github.com/dns-inspector/dns-inspector/blob/app-store/.github/CODE_OF_CONDUCT.md). These rules apply to **every member**, including project leaders.
