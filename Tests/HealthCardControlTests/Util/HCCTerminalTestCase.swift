//
//  Copyright (c) 2019 gematik GmbH
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//     http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import CardReaderProviderApi
import CardSimulationLoader
import GemCommonsKit
import HealthCardAccessKit
import XCTest

/// 'Abstract' TestCase that prepares and sets up a G2-kartensimulator (through CardSimulationLoader)
/// and a CardReaderProvider (through CardSimulationCardReaderProvider) to access the CardType and CardChannelType
open class HCCTerminalTestCase: XCTestCase {
    static let defaultConfigFile = "Configuration/configuration_EGKG2_80276883110000017222_gema5_TCP.xml"
    static let defaultHealthCardStatus: HealthCardStatus = .valid(cardType: .egk(generation: .g2))

#if os(macOS) || os(Linux)
    static var terminalResource: CardSimulatorTerminalResource!
    static var reader: CardReaderType!
    static var card: CardType!
    static var healthCard: HealthCard!
#endif

    open class func configFile() -> URL? {
        let bundle = Bundle(for: self)
        let path = bundle.testResourceFilePath(in: "Resources", for: self.defaultConfigFile)
        return path.asURL
    }

    open class func healthCardStatus() -> HealthCardStatus {
        return self.defaultHealthCardStatus
    }

#if os(macOS) || os(Linux)
    open class func createTerminalResource() -> CardSimulatorTerminalResource {
        guard let config = self.configFile() else {
            fatalError("No configFile")
        }
        let absolutePath = config.deletingLastPathComponent()
        let cardImagePath = XMLPathManipulatorHolder.relativeToAbsolutePathManipulator(
                with: XMLPathManipulatorHolder.CardConfigFileXMLPath,
                absolutePath: absolutePath
        )
        let channelContextPath = XMLPathManipulatorHolder.relativeToAbsolutePathManipulator(
                with: XMLPathManipulatorHolder.ChannelConfigFileXMLPath,
                absolutePath: absolutePath
        )
        let manipulators = [cardImagePath, channelContextPath]
        return CardSimulatorTerminalResource(url: config,
                                             configManipulators: manipulators,
                                             simulatorVersion: "2.7.9-395")
    }
#endif

#if os(macOS) || os(Linux)
    override open class func setUp() {
        super.setUp()
        terminalResource = self.createTerminalResource()
        do {
            try terminalResource.startUp()
        } catch let error {
            preconditionFailure("We cant start simulation runner: \(error)")
        }

        reader = HCCTerminalTestCase.terminalResource.reader
        do {
            try connectCard()
        } catch let error {
            preconditionFailure("CardTerminal could not connect card [\(error)]")
        }
    }

    override open class func tearDown() {
        terminalResource.shutDown()

        RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 3))
        SimulationManager.shared.clean()

        super.tearDown()
    }
#endif

    override open func setUp() {
        super.setUp()
        do {
            try createHealthCard()
        } catch let error {
            ALog("Could not create HealthCard: \(error)")
        }
    }

    override open func tearDown() {
        do {
            try disconnectCard()
        } catch let error {
            ALog("Could not disconnect card: \(error)")
        }
        super.tearDown()
    }

#if os(macOS) || os(Linux)
    open class func connectCard() throws {
        card = try reader.connect([:])
    }

    open func createHealthCard() throws {
        Self.healthCard = try HealthCard(card: Self.card, status: Self.healthCardStatus())
    }

    open func disconnectCard() throws {
        try Self.card.disconnect(reset: true)
    }
#endif
}
