import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../viewmodels/home_viewmodel.dart';
import 'event_detail_view.dart';

// ════════════════════════════════════════════════════════════════════
// HOME VIEW
// ════════════════════════════════════════════════════════════════════
/// Student home screen. Matches Figma design:
///   - Featured event hero banner (full-width, with image + gradient)
///   - "What's Happening This Week?" section with category filter
///   - "Coming Soon!" section
///   - One section per event category
///   - Bottom navigation (provided by MainView)
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const _bgColor = Color(0xFF0A0A0A);
  static const _cardRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Container(
      color: _bgColor,
      child: CustomScrollView(
        slivers: [
          // ── Featured banner ──────────────────────────────────────
          SliverToBoxAdapter(
            child: vm.isLoading
                ? _FeaturedSkeleton()
                : _FeaturedBanner(event: vm.featuredEvent),
          ),

          // ── "What's Happening This Week?" ────────────────────────
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: "What's Happening This Week?",
              trailing: _CategoryFilter(
                categories: vm.availableFilterCategories,
                selected: vm.selectedCategory,
                onSelected: vm.setCategory,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _HorizontalEventList(
              events: vm.thisWeekEvents,
              isLoading: vm.isLoading,
            ),
          ),

          // ── "Coming Soon!" ───────────────────────────────────────
          const SliverToBoxAdapter(
            child: _SectionHeader(title: 'Coming Soon!'),
          ),
          SliverToBoxAdapter(
            child: _HorizontalEventList(
              events: vm.comingSoonEvents,
              isLoading: vm.isLoading,
            ),
          ),

          // ── One section per category ─────────────────────────────
          for (final cat in vm.categoriesWithEvents) ...[
            SliverToBoxAdapter(child: _SectionHeader(title: cat)),
            SliverToBoxAdapter(
              child: _HorizontalEventList(
                events: vm.eventsByCategory(cat),
                isLoading: vm.isLoading,
              ),
            ),
          ],

          // ── Bottom padding so last section clears the nav bar ────
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// FEATURED BANNER
// ════════════════════════════════════════════════════════════════════
class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner({required this.event});
  final EventModel? event;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 280 + topPadding,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ─────────────────────────────────────
          if (event?.imageUrl != null)
            Image.network(
              event!.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _BannerPlaceholder(),
            )
          else
            const _BannerPlaceholder(),

          // ── Dark gradient overlay ─────────────────────────────────
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x88000000), Color(0xCC000000)],
              ),
            ),
          ),

          // ── Content on top of image ───────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Logo + Logout
                Row(
                  children: [
                    const Expanded(child: _RazakEventLogo()),
                    _LogoutButton(),
                  ],
                ),
                const Spacer(),
                // Event info at the bottom of the banner
                if (event != null) _BannerEventInfo(event: event!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo ─────────────────────────────────────────────────────────────
class _RazakEventLogo extends StatelessWidget {
  const _RazakEventLogo();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Razak',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w300,
            ),
          ),
          TextSpan(
            text: 'Event',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logout button ─────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => FirebaseAuth.instance.signOut(),
      icon: const Icon(Icons.logout, color: Colors.white, size: 18),
      label: const Text(
        'Logout',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
    );
  }
}

// ── Banner event info ─────────────────────────────────────────────────
class _BannerEventInfo extends StatelessWidget {
  const _BannerEventInfo({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM d, y').format(event.date),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                event.description,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // "Join Us!" button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EventDetailView(event: event)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E6BE6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Join Us!',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ── Placeholder when there's no image ────────────────────────────────
class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0800), Color(0xFF3D1500), Color(0xFFB85C1A)],
        ),
      ),
    );
  }
}

// ── Featured skeleton while loading ──────────────────────────────────
class _FeaturedSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(height: 280 + topPadding, color: const Color(0xFF1A1A1A));
  }
}

// ════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ════════════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// CATEGORY FILTER DROPDOWN
// ════════════════════════════════════════════════════════════════════
class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Category',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...categories.map(
            (cat) => ListTile(
              title: Text(cat, style: const TextStyle(color: Colors.white)),
              trailing: cat == selected
                  ? const Icon(Icons.check, color: Color(0xFF2E6BE6))
                  : null,
              onTap: () {
                onSelected(cat);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// HORIZONTAL EVENT LIST
// ════════════════════════════════════════════════════════════════════
class _HorizontalEventList extends StatelessWidget {
  const _HorizontalEventList({required this.events, required this.isLoading});
  final List<EventModel> events;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildSkeletons();
    if (events.isEmpty) return _buildEmpty();

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: events.length,
        itemBuilder: (_, i) => _EventCard(event: events[i]),
      ),
    );
  }

  Widget _buildSkeletons() {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) => Container(
          width: 140,
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'No events in this category yet.',
        style: TextStyle(color: Colors.white38, fontSize: 13),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// EVENT CARD
// ════════════════════════════════════════════════════════════════════
class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailView(event: event)),
        );
      },
      child: Container(
        width: 140,
        height: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1E1E1E),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: event.imageUrl != null
              ? Image.network(
                  event.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _CardPlaceholder(event: event),
                )
              : _CardPlaceholder(event: event),
        ),
      ),
    );
  }
}

// ── Placeholder card when there's no image ───────────────────────────
class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder({required this.event});
  final EventModel event;

  static const _gradients = [
    [Color(0xFF1A0800), Color(0xFFB85C1A)],
    [Color(0xFF0D1B2A), Color(0xFF2E6BE6)],
    [Color(0xFF0A1A0A), Color(0xFF2E7D32)],
    [Color(0xFF1A0A1A), Color(0xFF7B1FA2)],
  ];

  @override
  Widget build(BuildContext context) {
    // Pick a consistent gradient based on the event title
    final colors = _gradients[event.title.length % _gradients.length];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                event.category,
                style: const TextStyle(color: Colors.white, fontSize: 9),
              ),
            ),
            const Spacer(),
            Text(
              event.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('d MMM').format(event.date),
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
