/// The subscription entitlement tier for a Thunder user.
///
/// Designed as a simple enum extensible to future tiers (e.g. `.family`, `.lifetime`)
/// without a breaking change to existing entitlement checks. New cases added here
/// do not affect code that already handles `.free` and `.pro` explicitly —
/// exhaustive switches elsewhere in the codebase will surface unhandled cases
/// at compile time, which is the correct failure mode.
public enum ThunderEntitlement: Sendable, Equatable {
    /// The default tier. Full access to all free-tier features.
    case free

    /// Active subscription. Unlocks enhanced features across the suite.
    case pro
}
