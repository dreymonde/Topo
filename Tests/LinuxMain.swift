#if os(Linux)

import XCTest
@testable import InterchangeDataMapperTestSuite

XCTMain([
	testCase(NormalValueTests.allTests),
	testCase(OptionalValueTests.allTests),
	testCase(RawRepresentableValueTests.allTests)
])

#endif