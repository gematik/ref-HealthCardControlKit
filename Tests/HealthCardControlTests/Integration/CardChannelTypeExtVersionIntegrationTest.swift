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

import HealthCardAccessKit
@testable import HealthCardControlKit
import Nimble
import XCTest

final class CardChannelTypeExtVersionIntegrationTest: HCCTerminalTestCase {

    override class func configFile() -> URL? {
        let bundle = Bundle(for: self)
        let path = bundle.testResourceFilePath(
                in: "Resources",
                for: "Configuration/configuration_EGK_G2_1_80276883110000095711_GuD_TCP.xml"
        )
        return path.asURL
    }

    func testReadCardTypeAndVersion() {
        expect {
            var mType: HealthCardPropertyType?
            HCCTerminalTestCase.healthCard.currentCardChannel.readCardType()
                    .run(on: Executor.trampoline)
                    .on { event in
                        mType = event.value
                    }
            return mType
        } == HealthCardPropertyType.egk(generation: .g2_1)
    }
}
