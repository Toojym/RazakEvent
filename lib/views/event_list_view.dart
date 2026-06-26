import 'package:razak_event/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../viewmodels/event_viewmodel.dart';

class EventListView extends StatelessWidget {
  const EventListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text(
          'RazakEvent',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchBar(),
          _FilterBar(vm: vm),
          Expanded(child: _buildBody(vm)),
        ],
      ),
    );
  }

  Widget _buildBody(EventViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CustomLoadingIndicator(color: Colors.white),
      );
    }
    if (vm.errorMessage != null) {
      return Center(
        child: Text(
          vm.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (vm.events.isEmpty) {
      return const Center(
        child: Text(
          'No events found.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: vm.events.length,
      itemBuilder: (context, index) => _EventCard(event: vm.events[index]),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search events...',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white38),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final EventViewModel vm;
  const _FilterBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    final isUpcoming = vm.activeFilter.upcomingOnly;
    final isRange =
        !vm.activeFilter.upcomingOnly && vm.activeFilter.from != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _chip(
            label: 'Upcoming',
            selected: isUpcoming,
            onTap: () => isUpcoming ? vm.clearFilter() : vm.filterUpcoming(),
          ),
          const SizedBox(width: 8),
          _chip(
            label: 'Date Range',
            selected: isRange,
            onTap: () async {
              if (isRange) {
                vm.clearFilter();
                return;
              }
              await _pickDateRange(context, vm);
            },
          ),
          if (isUpcoming || isRange) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: vm.clearFilter,
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context, EventViewModel vm) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (picked != null) {
      vm.filterByRange(from: picked.start, to: picked.end);
    }
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              image: event.displayImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(event.displayImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: event.displayImageUrl == null
                ? const Center(
                    child: Icon(Icons.event, color: Colors.white24, size: 48),
                  )
                : null,
          ),
          // Event details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white38,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(event.date),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white38,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.location,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '${event.attendeeMeritPoints} merit pts',
                      style: const TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} · '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
