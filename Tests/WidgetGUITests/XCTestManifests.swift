import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    [
      testCase(FlexTests.allTests),
      testCase(PropertyTests.allTests),
      testCase(StyleTests.allTests)
    ]
  }
#endif
