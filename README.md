# HealthCardControlKit

Controlling/Use-case framework for accessing smart cards of the telematic infrastructure.

## API Documentation

Generated API docs are available at <https://gematik.github.io/ref-HealthCardControlKit>.

## License

Licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).

## Overview

This library can be used to realize use cases for interacting with a German Health Card
(eGk, elektronische Gesundheitskarte) via a mobile device.

Typically you would use this library as the high level API gateway for your mobile application
to send predefined command chains to the Health Card and interpret the responses.

For more info, please find the low level project [HealthCardAccessKit](https://github.com/gematik/ref-HealthCardAccessKit)
and a [Demo App](https://github.com/gematik/ref-OpenHealthCardApp-iOS) on GitHub.

See the [Gematik GitHub IO](https://gematik.github.io/) page for a more general overview.

## Getting Started

HealthCardControlKit requires Swift 5.1.

### Setup for integration

-   **Carthage:** Put this in your `Cartfile`:

        github "gematik/ref-HealthCardControlKit" ~> 1.0

### Setup for development

You will need [Bundler](https://bundler.io/), [XcodeGen](https://github.com/yonaskolb/XcodeGen)
and [fastlane](https://fastlane.tools) to conveniently use the established development environment.

1.  Update ruby gems necessary for build commands

        $ bundle install --path vendor/gems

2.  Checkout (and build) dependencies and generate the xcodeproject

        $ bundle exec fastlane setup

3.  Build the project

        $ bundle exec fastlane build_all [build_mac, build_ios]

## Code Samples

Take the necessary preparatory steps for signing a challenge on the Health Card, then sign it.

    let challenge = Data([0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8])
    let format2Pin = try Format2Pin(pincode: "123456")
    CardSimulationTerminalTestCase.healthCard
            .verify(pin: format2Pin, type: EgkFileSystem.Pin.mrpinHome)
            .flatMap { _ in
                CardSimulationTerminalTestCase.healthCard.sign(challenge: challenge)
            }
            .run(on: Executor.trampoline)

Encapsulate the [PACE protocol](https://www.bsi.bund.de/DE/Publikationen/TechnischeRichtlinien/tr03110/index_htm.html)
steps for establishing a secure channel with the Health Card and expose only a simple API call .

    try KeyAgreement.Algorithm.idPaceEcdhGmAesCbcCmac128.negotiateSessionKey(
                    channel: CardSimulationTerminalTestCase.healthCard.currentCardChannel,
                    can: can,
                    writeTimeout: 0,
                    readTimeout: 10)
            .run(on: Executor.trampoline)

See the integration tests [Tests/HealthCardControlTests/Integration](../../Tests/HealthCardControlTests/Integration)
for more already implemented use cases.
