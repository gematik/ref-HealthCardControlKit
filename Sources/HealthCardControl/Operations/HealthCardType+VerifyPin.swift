//
//  Copyright (c) 2020 gematik GmbH
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

import Foundation
import HealthCardAccessKit

extension HealthCardType {

    /// Enter Password for MrPIN
    ///
    /// - Parameter pin: `Format2Pin` holds the MrPin information for the `HealthCardType`
    ///
    /// - Returns: Executable that tries to verify the given PIN information against MrPin.
    ///
    /// - Note: Only supports eGK Card types
    public func verifyMrPinHome(pin: Format2Pin) -> Executable<HealthCardResponseType> {
        return Executable<HealthCardResponseType>
                .evaluate {
                    guard let mrPinHome = self.status.type?.mrPinHome else {
                        throw HealthCard.Error.unsupportedCardType
                    }
                    return mrPinHome
                }
                .flatMap { (mrPinHome: Password) in
                    let verifyPasswordParameter = (mrPinHome, false, pin)
                    return HealthCardCommand.Verify.verify(password: verifyPasswordParameter)
                            .execute(on: self)
                }
    }
}

extension HealthCardPropertyType {
    /// Return the card's mrPinHome information
    /// - Note: Only supports eGK Card types
    public var mrPinHome: Password? {
        switch self {
        case .egk: return EgkFileSystem.Pin.mrpinHome
                // Other cards are unsupported for now
        default: return nil
        }
    }
}
