//
//  Copyright (c) 2019 gematik - Gesellschaft für Telematikanwendungen der Gesundheitskarte mbH
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
import Foundation
import HealthCardAccessKit

enum CardAid: ApplicationIdentifier {
    case egk = "D2760001448000"
    case hba = "D27600014601"
    case smcb = "D27600014606"

    /// 5.3.4 MF / EF.Version2 (SMC-B)
    /// 5.3.8 MF / EF.Version2 (eGK)
    /// 5.3.5 MF / EF.Version2 (HBA)
    /// - Note: for all three the shortFileIdentifier is the same
    var sfi: ShortFileIdentifier {
        // swiftlint:disable:next force_unwrapping
        return EgkFileSystem.EF.version2.sfid!
    }

    func from(version: CardVersion2) throws -> HealthCardPropertyType {
        guard let generation = version.generation() else {
            throw HealthCard.Error.illegalGeneration(version: version)
        }
        switch self {
        case .egk:
            return .egk(generation: generation)
        case .hba:
            return .hba(generation: generation)
        case .smcb:
            return .smcb(generation: generation)
        }
    }
}

extension HealthCard {
    public enum Error: Swift.Error {
        case unknownCardType(aid: ApplicationIdentifier?)
        case illegalGeneration(version: CardVersion2)
    }
}

extension CardChannelType {

    var expectedLengthWildcard: Int {
        if extendedLengthSupported {
            return APDU.expectedLengthWildcardExtended
        }
        return APDU.expectedLengthWildcardShort
    }

    /// Read EF.Version2 and determine `HealthCardPropertyType`
    /// - Parameters:
    ///     - writeTimeout: interval in seconds
    ///     - readTimeout: interval in seconds
    /// - Returns: Executor that emits a HealthCardPropertyType on successful recognition of the AID and EF.Version2
    public func readCardType(writeTimeout: TimeInterval = 30.0, readTimeout: TimeInterval = 30.0)
                    -> Executable<HealthCardPropertyType> {
        let channel = self
        return Executable<HealthCardCommand>
                .evaluate {
                    try HealthCardCommand.Select.selectRootRequestingFcp(expectedLength: channel.expectedLengthWildcard)
                }
                .flatMap {
                    $0.execute(on: self, writeTimeout: writeTimeout, readTimeout: readTimeout)
                }
                .map {
                    let fcp = try FileControlParameter.parse(data: $0.data ?? Data.empty)
                    guard let aid = fcp.applicationIdentifier else {
                        throw HealthCard.Error.unknownCardType(aid: nil)
                    }
                    guard let card = CardAid(rawValue: aid) else {
                        throw HealthCard.Error.unknownCardType(aid: aid)
                    }
                    return card
                }
                .flatMap { (cardAid: CardAid) in
                    return try HealthCardCommand.Read.readFileCommand(
                                    with: cardAid.sfi,
                                    ne: channel.expectedLengthWildcard
                            )
                            .execute(on: channel, writeTimeout: writeTimeout, readTimeout: readTimeout)
                            .map { response in
                                try cardAid.from(version: CardVersion2(data: response.data ?? Data.empty))
                            }
                }
    }
}
