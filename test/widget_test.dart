import 'package:flutter_test/flutter_test.dart';
import 'package:jobscam_guard/services/mock_data_service.dart';
import 'package:jobscam_guard/models/job_scan_model.dart';

void main() {
  // Initialize test binding
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockDataService Unit Tests', () {
    test('Initializes with default mock scans and alerts', () {
      final service = MockDataService();

      expect(service.scans.length, greaterThanOrEqualTo(1));
      expect(service.scamAlerts.length, greaterThanOrEqualTo(1));
      expect(service.notifications.length, greaterThanOrEqualTo(1));
    });

    test('Theme toggle updates theme mode state', () {
      final service = MockDataService();
      final initialMode = service.themeMode;
      service.toggleTheme();
      expect(service.themeMode, isNot(equals(initialMode)));
    });

    test('Add job scan updates logs and scan result', () async {
      final service = MockDataService();
      final initialScansLength = service.scans.length;

      await service.runJobScan(
        companyName: 'Apex Data entry Solutions',
        jobTitle: 'Telegram Clerk',
        jobUrl: 'http://apex-scam.net',
        description: 'Send us \$100 check immediately on Telegram.',
      );

      expect(service.scans.length, equals(initialScansLength + 1));
      expect(service.latestScanResult?.status, equals(ScanStatus.scam));
    });

    test('Delete job scan removes matching log', () async {
      final service = MockDataService();
      // Run a scan so we have a known id to delete
      await service.runJobScan(
        companyName: 'Test Corp',
        jobTitle: 'Remote Agent',
        jobUrl: 'http://test.net',
        description: 'Standard remote role',
      );
      final initialLength = service.scans.length;
      final firstScanId = service.scans.first.id;

      service.deleteScan(firstScanId);

      expect(service.scans.length, equals(initialLength - 1));
      expect(service.scans.any((s) => s.id == firstScanId), isFalse);
    });

    test('Submit scam report adds to trending alerts list', () async {
      final service = MockDataService();
      final initialAlertsLength = service.scamAlerts.length;

      await service.submitScamReport(
        companyName: 'Cyber Phishing Corp',
        website: 'www.cyber-phish.xyz',
        jobUrl: 'http://link.xyz',
        description: 'Fake recruitment interview scam targeting developers.',
        category: 'Identity Theft / Harvesting',
      );

      expect(service.scamAlerts.length, equals(initialAlertsLength + 1));
      expect(service.scamAlerts.first.companyName, equals('Cyber Phishing Corp'));
    });

    test('Computed stats getters reflect scan list correctly', () async {
      final service = MockDataService();
      await service.runJobScan(
        companyName: 'Safe Recruiter Inc',
        jobTitle: 'Data Analyst',
        jobUrl: 'https://saferecruiter.com/jobs/data-analyst',
        description: 'Standard full-time data analyst role with corporate email.',
      );

      expect(service.totalJobsScanned, equals(service.scans.length));
      expect(service.safeJobs + service.suspiciousJobs + service.scamJobs,
          equals(service.totalJobsScanned));
    });
  });
}

