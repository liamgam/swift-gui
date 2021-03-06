import Events

public protocol AnyObservableProtocol: class {
  var any: AnyObservableProperty { get }
}

// TODO: maybe have Observable as base protocol with onChanged and then implement things like ObservableValue, ObservableArray on top of that
// TODO: might rename to Observable and remove Observable class
public protocol ObservableProtocol: AnyObservableProtocol {
  associatedtype Value
  var value: Value { get }
  var onChanged: EventHandlerManager<ObservableChangedEventData<Value>> { get }
}

internal protocol AnyEquatableObservableProtocol {
  func valuesEqual(_ value1: Any?, _ value2: Any?) -> Bool
}

public struct ObservableChangedEventData<Value> {
  public var old: Value?
  public var new: Value

  public init(old: Value?, new: Value) {
    self.old = old
    self.new = new
  }
}