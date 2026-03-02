class MockConfig {
  const MockConfig({
    this.minDelayMs = 200,
    this.maxDelayMs = 1500,
  });
  final int minDelayMs;
  final int maxDelayMs;

  static const standard = MockConfig();
  static const instant = MockConfig(minDelayMs: 0, maxDelayMs: 0);
}
