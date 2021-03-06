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

import CardSimulationTerminalTestCase
import Foundation
import GemCommonsKit
import HealthCardAccessKit
@testable import HealthCardControlKit
import Nimble
import XCTest

final class ReadAutCertificateR2048Test: CardSimulationTerminalTestCase {
    private let dedicatedFile = DedicatedFile(
            aid: EgkFileSystem.DF.ESIGN.aid,
            fid: EgkFileSystem.EF.esignCChAutR2048.fid
    )
    private var expectedCertificate: Data!

    override func setUp() {
        super.setUp()

        let bundle = Bundle(for: ReadAutCertificateR2048Test.self)
        let path = bundle.testResourceFilePath(in: "Resources", for: "Certificates/esignCChAutR2048_2.cer").asURL
        do {
            expectedCertificate = try Data(contentsOf: path)
        } catch let error {
            ALog("Could not read certificate file: \(path)\nError: \(error)")
        }
    }

    func testReadAutCertificate2048() {
        let response = CardSimulationTerminalTestCase.healthCard
                .readAutCertificate()
                .run(on: Executor.trampoline)
                .test()
                .value
        expect(response?.info) == .efAutR2048
        expect(response?.certificate) == expectedCertificate
    }
}
