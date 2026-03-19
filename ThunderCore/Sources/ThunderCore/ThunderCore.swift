/// The shared library powering all Thunder apps.
///
/// `ThunderCore` is the single shared data layer for the Thunder suite.
/// All domain models, services, schema definitions, and shared business
/// logic live here. App targets import this library — they do not define
/// their own data layer.
public enum ThunderCore {
    /// The current semantic version of the ThunderCore library.
    public static let version: String = "1.0.0"
}
