/// Project-level constants for the Thunder suite.
///
/// All Thunder apps reference these constants — nothing is hardcoded
/// in individual app targets. Adding a new app to the suite means
/// pointing it at the same constants, not creating new ones.
public enum ThunderConfiguration {

    /// The shared CloudKit container identifier used by every app in the suite.
    ///
    /// This container was provisioned at `iCloud.com.thead9.thunder` and is
    /// the single store backing all Thunder apps across all devices.
    /// It is passed to `ModelContainer` configuration and to any CloudKit
    /// API calls that require a container reference.
    ///
    /// Never hardcode this string in an app target.
    public static let cloudKitContainerIdentifier = "iCloud.com.thead9.thunder"
}
