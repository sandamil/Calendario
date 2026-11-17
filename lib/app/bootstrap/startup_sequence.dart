/// Runs every awaited startup phase before the normal provider tree is mounted.
Future<void> runPreProviderStartup({
  required Future<void> Function() replayExternalManifest,
  required Future<void> Function() recoverLegacyJournal,
  required Future<void> Function() initializeNotifications,
  required Future<void> Function() initializeMemory,
  required Future<void> Function() initializeDateFormatting,
}) async {
  await replayExternalManifest();
  await recoverLegacyJournal();
  await Future.wait<void>([initializeNotifications(), initializeMemory()]);
  await initializeDateFormatting();
}
