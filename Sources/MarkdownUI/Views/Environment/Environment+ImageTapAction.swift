import SwiftUI

extension EnvironmentValues {
  var onImageTap: ((URL?) -> Void)? {
    get { self[ImageTapActionKey.self] }
    set { self[ImageTapActionKey.self] = newValue }
  }
}

private struct ImageTapActionKey: EnvironmentKey {
  static var defaultValue: ((URL?) -> Void)? = nil
}