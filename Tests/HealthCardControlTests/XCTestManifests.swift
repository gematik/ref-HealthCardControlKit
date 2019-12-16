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

import XCTest

#if !os(macOS) && !os(iOS)
/// Runs all tests in HealthCardControlKit
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ECPointTest.allTests),
        testCase(EllipticCurveTest.allTests),
        testCase(AESTest.allTests),
        testCase(KeyDerivationFunctionTest.allTests),
        testCase(HealthCardTypeExtEfCardAccessIntTest.allTests),
        testCase(KeyAgreementIntegrationTest.allTests),
        testCase(SelectCommandIntegrationTest.allTests),
        testCase(CardAccessNumberTest.allTests),
        testCase(EcdhKeyPairGeneratorTest.allTests),
        testCase(KeyAgreementTest.allTests),
        testCase(AES128PaceKeyTest.allTests)
    ]
}
#endif
