import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/mock_data_service.dart';
import '../../models/job_scan_model.dart';
import '../../widgets/empty_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Safe', 'Suspicious', 'Scam'
  String _selectedSort = 'date_desc'; // 'date_desc', 'date_asc', 'risk_desc', 'risk_asc'

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

  void _exportPdf(JobScan scan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf_rounded, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Exporting Report...'),
          ],
        ),
        content: Text('Generating official PDF security audit for "${scan.companyName}"...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('PDF report for ${scan.companyName} saved to Downloads.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort Scans By',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(),
                  RadioListTile<String>(
                    title: const Text('Date: Newest First'),
                    value: 'date_desc',
                    groupValue: _selectedSort,
                    onChanged: (val) {
                      setState(() => _selectedSort = val!);
                      setModalState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Date: Oldest First'),
                    value: 'date_asc',
                    groupValue: _selectedSort,
                    onChanged: (val) {
                      setState(() => _selectedSort = val!);
                      setModalState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Risk Score: Highest First'),
                    value: 'risk_desc',
                    groupValue: _selectedSort,
                    onChanged: (val) {
                      setState(() => _selectedSort = val!);
                      setModalState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Risk Score: Lowest First'),
                    value: 'risk_asc',
                    groupValue: _selectedSort,
                    onChanged: (val) {
                      setState(() => _selectedSort = val!);
                      setModalState(() {});
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailsDialog(JobScan scan, Color statusColor) {
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
              if (scan.jobUrl.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  scan.jobUrl,
                  style: const TextStyle(fontSize: 11, color: AppColors.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
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
              if (scan.location != null && scan.location!.isNotEmpty && scan.location != 'Not Provided') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Location: ${scan.location!} (${scan.locationStatus?.toUpperCase()})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
              if (scan.status == ScanStatus.scam && scan.primaryScamType != null && scan.primaryScamType!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Scam Classification: ${scan.primaryScamType!}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger),
                ),
              ],
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
              if (scan.attachmentName != null) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.attach_file_rounded, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        scan.attachmentName!,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.danger),
            onPressed: () {
              Navigator.pop(context);
              _exportPdf(scan);
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = Provider.of<MockDataService>(context);

    // Apply Filter
    List<JobScan> filteredList = service.scans.where((scan) {
      final matchesSearch = scan.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          scan.jobTitle.toLowerCase().contains(_searchQuery.toLowerCase());

      if (_selectedFilter == 'All') return matchesSearch;
      if (_selectedFilter == 'Safe') return matchesSearch && scan.status == ScanStatus.safe;
      if (_selectedFilter == 'Suspicious') return matchesSearch && scan.status == ScanStatus.suspicious;
      if (_selectedFilter == 'Scam') return matchesSearch && scan.status == ScanStatus.scam;
      return matchesSearch;
    }).toList();

    // Apply Sorting
    filteredList.sort((a, b) {
      if (_selectedSort == 'date_desc') return b.scanDate.compareTo(a.scanDate);
      if (_selectedSort == 'date_asc') return a.scanDate.compareTo(b.scanDate);
      if (_selectedSort == 'risk_desc') return b.riskPercentage.compareTo(a.riskPercentage);
      if (_selectedSort == 'risk_asc') return a.riskPercentage.compareTo(b.riskPercentage);
      return 0;
    });

    Widget _buildFilterChip(String label) {
      final isSelected = _selectedFilter == label;
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: FilterChip(
          label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black))),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedFilter = label;
            });
          },
          selectedColor: AppColors.primary,
          checkmarkColor: Colors.white,
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          side: BorderSide(color: isSelected ? Colors.transparent : (isDark ? AppColors.borderDark : AppColors.borderLight)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Logs & History'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Sort bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Search company or role...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.sort_rounded, color: AppColors.primary),
                      onPressed: _showSortOptions,
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            Container(
              height: 48,
              padding: const EdgeInsets.only(bottom: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Safe'),
                  _buildFilterChip('Suspicious'),
                  _buildFilterChip('Scam'),
                ],
              ),
            ),

            // History Log List
            Expanded(
              child: filteredList.isEmpty
                  ? EmptyState(
                      title: 'No Logs Found',
                      description: _searchQuery.isNotEmpty
                          ? 'No history matches your search query. Try typing something else.'
                          : 'You have not scanned any job proposals yet. Go to the Scan tab to analyze your first job.',
                      icon: Icons.history_toggle_off_rounded,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final scan = filteredList[index];
                        final dateString = DateFormat('MMM d, yyyy h:mm a').format(scan.scanDate);
                        final statusColor = _getStatusColor(scan.status);

                        return Dismissible(
                          key: Key(scan.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Log?'),
                                content: Text('Delete "${scan.companyName}" scan logs permanent?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) {
                            service.deleteScan(scan.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Scan log deleted.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  scan.status == ScanStatus.safe
                                      ? Icons.verified_user_rounded
                                      : (scan.status == ScanStatus.suspicious
                                          ? Icons.gpp_maybe_rounded
                                          : Icons.gpp_bad_rounded),
                                  color: statusColor,
                                  size: 24,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      scan.companyName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${scan.riskPercentage.toStringAsFixed(1)}%',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: statusColor),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    scan.jobTitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (scan.status == ScanStatus.scam && scan.primaryScamType != null && scan.primaryScamType!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      scan.primaryScamType!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dateString,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? AppColors.darkTextSecondary.withOpacity(0.5) : AppColors.lightTextSecondary.withOpacity(0.6),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          scan.statusText.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.chevron_right_rounded,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                              onTap: () => _showDetailsDialog(scan, statusColor),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
