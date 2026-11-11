import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/enums.dart';
import '../../providers/report_providers.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/report_card.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(reportFilterProvider);
    final filtered = ref.watch(filteredAllReportsProvider);
    final async = ref.watch(allReportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Reports')),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: TextField(
            onChanged: ref.read(reportFilterProvider.notifier).setQuery,
            decoration: const InputDecoration(
                hintText: 'Search by title, location, reporter…',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: StatusFilterChips(
              selected: filter.status,
              onChanged: ref.read(reportFilterProvider.notifier).setStatus),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final c in ReportCategory.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c.label),
                    selected: filter.category == c,
                    onSelected: (_) => ref
                        .read(reportFilterProvider.notifier)
                        .setCategory(filter.category == c ? null : c),
                    showCheckmark: false,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: filter.category == c
                            ? Colors.white
                            : AppColors.textDark),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Text(
              '${filtered.length} report${filtered.length == 1 ? '' : 's'}',
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Center(
                child: Text('Could not load reports.\n$e',
                    textAlign: TextAlign.center)),
            data: (_) => filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No reports found',
                    message: 'Try a different search or filter.')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => ReportCard(report: filtered[i]),
                  ),
          ),
        ),
      ]),
    );
  }
}