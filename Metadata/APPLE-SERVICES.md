# Apple service decisions

Checked against Apple's primary documentation on 15 November 2026. No external football feed is used or required. All tournament data is entered by its organizers. Sample content is explicitly marked and excluded from iCloud, widget snapshots and scheduled reminders.

- [CloudKit shared records](https://developer.apple.com/documentation/cloudkit/shared-records): custom private zones and record-root CKShare; participants use sharedCloudDatabase. Private database discovery uses record zones and known root IDs, without a public query or server.
- [CKShare](https://developer.apple.com/documentation/cloudkit/ckshare): CKSharingSupported is enabled. Apple documents up to 100 participants per share, each needing an active iCloud account. The app does not promise unlimited collaboration.
- [Sharing CloudKit data](https://developer.apple.com/documentation/cloudkit/sharing-cloudkit-data-with-other-icloud-users): UICloudSharingController manages private invitations and read/write or read-only permissions. Scene and application delegates accept invitations. Read/write invitees are trusted co-organizers; UI review is not a server security boundary.
- [CloudKit quotaExceeded](https://developer.apple.com/documentation/cloudkit/ckerror/quotaexceeded): private database storage is subject to the user's iCloud storage. The app handles quota and network errors while retaining local changes. No public database, paid API, custom backend, APNs sender, or automatic billing integration is used.
- [Sign in with Apple authentication](https://developer.apple.com/documentation/authenticationservices/implementing-user-authentication-with-sign-in-with-apple): native authorization and credential-state checking; optional local organizer profile. Email and tokens are not persisted. Real service testing needs provisioned capabilities.

Conflict handling merges independent match reports, append-only roster additions, individual timestamped ballots and moderation decisions, then uses ifServerRecordUnchanged with bounded retry. A later edit of the same match wins. Concurrent writes do not rely on an unconditional overwrite. The data is community coordination, not a tamper-resistant competition ledger.

Each tournament has one private custom zone and one known root record (`NeighborhoodBoard`, `payload` as Bytes with a version marker and LZFSE compression). CKShare shares that root. Schema must be initialized under a signed development build and deployed through CloudKit Console before distributing a production build. No dashboard changes are made by this task.

The app declares remote-notification and Push Notifications as requested, but does not register an APNs sender or promise real-time events. Notifications are scheduled locally at launch, after a result edit and after synchronization. There is no unnecessary background fetch loop.

The required WidgetKit extension is a separate native target. A third target is UI/domain tests. This is the working Apple SDK interpretation of the one-app-target requirement. Six authored Swift files include the test file. Individual specification explicitly excludes Live Activities; no unused ActivityKit capability or activity is declared.
