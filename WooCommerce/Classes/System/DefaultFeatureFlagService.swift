struct DefaultFeatureFlagService: FeatureFlagService {
    func isFeatureFlagEnabled(_ featureFlag: FeatureFlag) -> Bool {
        switch featureFlag {
        case .productList:
            // TODO-jaclync: remove
            return true
            return BuildConfiguration.current == .localDeveloper
        case .stats:
            return true
        default:
            return true
        }
    }
}
