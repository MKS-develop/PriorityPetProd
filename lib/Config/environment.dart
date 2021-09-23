class Environment {
  static const DEV = 'DEV';
  static const QA = 'QA';
  static const PROD = 'PROD';
  static const FLAVOR = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'DEV'
  );
}