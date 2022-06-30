import Foundation

enum Product: String, CaseIterable {
  case pesdk = "PE.SDK"
  case vesdk = "VE.SDK"
}

class ExampleItem: Hashable {

  // MARK: - Properties

  let title: String
  let subtitle: String?
  let examples: [ExampleItem]

  let products: Set<Product>
  let swiftExample: Example.Type?
  let objCExample: Example.Type?

  // MARK: - Initializers

  init(title: String, examples: [ExampleItem] = []) {
    self.title = title
    self.examples = examples
    subtitle = nil
    products = []
    swiftExample = nil
    objCExample = nil
  }

  init(title: String, subtitle: String, products: Set<Product>, swiftExample: Example.Type?, objCExample: Example.Type?) {
    precondition(swiftExample != nil || objCExample != nil)
    self.title = title
    self.subtitle = subtitle
    self.products = products
    self.swiftExample = swiftExample
    self.objCExample = objCExample
    examples = []
  }

  // MARK: - Hashable

  private let identifier = UUID()

  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }

  static func == (lhs: ExampleItem, rhs: ExampleItem) -> Bool {
    lhs.identifier == rhs.identifier
  }
}
