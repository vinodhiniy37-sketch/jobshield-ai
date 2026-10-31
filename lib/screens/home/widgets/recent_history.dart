import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../services/mock_data_service.dart';
import '../../../models/job_scan_model.dart';
import '../../history/history_screen.dart';
import '../../main_screen.dart';

class RecentHistory extends StatelessWidget {
  const RecentHistory({Key? key}) : super(key: key);

  Color _getStatusColor(ScanStatus status) {
    switch (status) {
      case ScanStatus.safe:
        return AppColors.success;
      case ScanStatus.lowRisk:
        return const Color(0xFF10B981);
      case ScanStatus.suspicious:
        return AppColors.warning;
      case ScanStatus.highRisk:
        return const Color(0xFFF97316);
      case ScanStatus.scam:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dataService = Provider.of<MockDataService>(context);
    final history = dataService.scans.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Scan History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
                child: const Text('View History', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ),
        if (history.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 32,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No scans logged yet.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final JobScan scan = history[index];
              final dateString = DateFormat('MMM d, h:mm a').format(scan.scanDate);
              final statusColor = _getStatusColor(scan.status);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      scan.status == ScanStatus.safe
                          ? Icons.verified_user_rounded
                          : (scan.status == ScanStatus.suspicious
                              ? Icons.gpp_maybe_rounded
                              : Icons.gpp_bad_rounded),
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    scan.companyName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.jobTitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateString,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.darkTextSecondary.withOpacity(0.5) : AppColors.lightTextSecondary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${scan.riskPercentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: statusColor,
                            ),
                          ),
                          Text(
                            scan.statusText,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to history and expand details or open dialog details
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Row(
                          children: [
                            Icon(
                              scan.status == ScanStatus.safe
                                  ? Icons.verified_user_rounded
                                  : (scan.status == ScanStatus.suspicious
                                      ? Icons.gpp_maybe_rounded
                                      : Icons.gpp_bad_rounded),
                              color: statusColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                scan.companyName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                scan.jobTitle,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('Safety Status: ', style: TextStyle(fontSize: 12)),
                                  Text(
                                    scan.statusText.toUpperCase(),
                                    style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 12),
                                  ),
                                  const Spacer(),
                                  Text('Risk: ${scan.riskPercentage.toStringAsFixed(1)}%',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 12)),
                                ],
                              ),
                              const Divider(height: 24),
                              const Text('Key Finding Explanations:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 6),
                              ...scan.reasons.map((r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('• ', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                                        Expanded(child: Text(r, style: const TextStyle(fontSize: 12))),
                                      ],
                                    ),
                                  )),
                              const SizedBox(height: 12),
                              const Text('Recommendations:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 6),
                              ...scan.recommendations.map((rec) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('✓ ', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                                        Expanded(child: Text(rec, style: const TextStyle(fontSize: 12))),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
