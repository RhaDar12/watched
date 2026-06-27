import 'dart:io';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/spotlight_background.dart';
import '../../../data/database_helper.dart';
import '../../../data/models/watched_item.dart';
import '../../main/screens/main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedGenre;
  String _searchQuery = '';

  List<WatchedItem> _allItems = [];
  bool _isLoading = true;

  static const List<String> _genres = [
    'Action',
    'Adventure',
    'Animation',
    'Biography',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Fantasy',
    'History',
    'Horror',
    'Musical',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'War',
    'Western',
  ];

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure MainScreen is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
    });
  }

  Future<void> _loadItems() async {
    final user = MainScreen.of(context)?.currentUser;
    if (user != null && user.id != null) {
      final items = await DatabaseHelper.instance.getAllItems(user.id!);
      if (mounted) {
        setState(() {
          _allItems = items;
          _isLoading = false;
        });
      }
    }
  }

  List<WatchedItem> _filteredItems(int tabIndex) {
    var items = _allItems;

    // Filter by category based on tab
    if (tabIndex == 1) {
      items = items.where((i) => i.category == 'Film').toList();
    } else if (tabIndex == 2) {
      items = items.where((i) => i.category == 'Series').toList();
    }

    // Filter by genre
    if (_selectedGenre != null) {
      items = items.where((i) {
        final genres = i.genre.split(',').map((g) => g.trim()).toList();
        return genres.contains(_selectedGenre);
      }).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      items = items
          .where((i) =>
              i.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SpotlightBackground(
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              toolbarHeight: 60,
              titleSpacing: AppDimensions.screenMargin,
              title: Row(
                children: [
                  // Hamburger
                  Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () => MainScreen.of(context)?.openDrawer(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.cardLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // WATCHED logo text — centered
                  Text(
                    'WATCHED',
                    style: AppTypography.title.copyWith(
                      letterSpacing: 6,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  // Avatar button (replaces search)
                  Builder(
                    builder: (ctx) {
                      final currentUser = MainScreen.of(context)?.currentUser;
                      final avatarPath = currentUser?.profilePhotoPath;

                      return GestureDetector(
                        onTap: () {
                          MainScreen.of(context)?.onTabTapped(2);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.cardLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                            image: avatarPath != null
                                ? DecorationImage(
                                    image: FileImage(File(avatarPath)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: avatarPath == null
                              ? const Icon(
                                  Icons.person,
                                  color: AppColors.textPrimary,
                                  size: 18,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: Column(
                  children: [
                    // TabBar
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.screenMargin,
                      ),
                      child: TabBar(
                        indicatorColor: Colors.white,
                        indicatorWeight: 2,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white, // 100% white
                        labelStyle: AppTypography.label.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          fontSize: 13,
                        ),
                        unselectedLabelStyle: AppTypography.label.copyWith(
                          letterSpacing: 2,
                          fontSize: 13,
                        ),
                        tabs: const [
                          Tab(text: 'ALL'),
                          Tab(text: 'FILM'),
                          Tab(text: 'SERIES'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Search bar + Genre dropdown row
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.screenMargin,
                      ),
                      child: Row(
                        children: [
                          // Search bar
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.card.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      AppColors.border.withValues(alpha: 0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (val) =>
                                          setState(() => _searchQuery = val),
                                      style: AppTypography.body
                                          .copyWith(fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: 'Search...',
                                        hintStyle:
                                            AppTypography.body.copyWith(
                                          color: AppColors.textHint,
                                          fontSize: 13,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Genre dropdown
                          Container(
                            height: 40,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.card.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    AppColors.border.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGenre,
                                hint: Text(
                                  'All Genres',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.textSecondary,
                                  size: 16,
                                ),
                                dropdownColor: AppColors.card,
                                isDense: true,
                                style: AppTypography.label
                                    .copyWith(fontSize: 11),
                                items: [
                                  DropdownMenuItem<String>(
                                    value: null,
                                    child: Text(
                                      'All Genres',
                                      style: AppTypography.label
                                          .copyWith(fontSize: 11),
                                    ),
                                  ),
                                  ..._genres.map((g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(
                                          g,
                                          style: AppTypography.label
                                              .copyWith(fontSize: 11),
                                        ),
                                      )),
                                ],
                                onChanged: (val) =>
                                    setState(() => _selectedGenre = val),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            body: Builder(
              builder: (context) {
                // Access DefaultTabController from this context
                return TabBarView(
                  children: [
                    _buildContentTab(0), // ALL items
                    _buildContentTab(1), // Film only
                    _buildContentTab(2), // Series only
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentTab(int tabIndex) {
    final filtered = _filteredItems(tabIndex);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Movie grid or empty state
        if (filtered.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenMargin,
              AppDimensions.sectionSpacing,
              AppDimensions.screenMargin,
              100,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppDimensions.gridGutter,
                crossAxisSpacing: AppDimensions.gridGutter,
                childAspectRatio: 0.6,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => const _EmptyMovieCard(),
                childCount: 6,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenMargin,
              AppDimensions.sectionSpacing,
              AppDimensions.screenMargin,
              100,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppDimensions.gridGutter,
                crossAxisSpacing: AppDimensions.gridGutter,
                childAspectRatio: 0.50,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filtered[index];
                  return _MovieCard(
                    item: item,
                    onTap: () async {
                      await Navigator.of(context).pushNamed(
                        '/detail',
                        arguments: item,
                      );
                      _loadItems();
                    },
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }
}

/// Empty placeholder card with film icon and empty text.
class _EmptyMovieCard extends StatelessWidget {
  const _EmptyMovieCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_creation_outlined,
            color: AppColors.textDisabled,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            'Belum ada\nfilm/series',
            textAlign: TextAlign.center,
            style: AppTypography.small.copyWith(
              color: AppColors.textDisabled,
              fontSize: 8,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Movie card displaying poster, title, and rating stars.
class _MovieCard extends StatelessWidget {
  final WatchedItem item;
  final VoidCallback? onTap;

  const _MovieCard({
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final genres = item.genre.split(',').map((e) => e.trim()).toList();
    final firstGenre = genres.isNotEmpty ? genres.first : '';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.card,
              ),
              child: Hero(
                tag: 'poster_${item.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.posterPath != null && item.posterPath!.isNotEmpty
                      ? Image.file(
                          File(item.posterPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, error, stackTrace) =>
                              _posterPlaceholder(),
                        )
                      : _posterPlaceholder(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Title
          Text(
            item.title,
            style: AppTypography.label.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Genre Chip (just show the first one due to space)
          if (firstGenre.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                firstGenre.toUpperCase(),
                style: AppTypography.small.copyWith(
                  fontSize: 7,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          const SizedBox(height: 4),
          // Rating stars
          Row(
            children: List.generate(5, (i) {
              final rating = (item.rating ?? 0) / 2; // 10-scale to 5-star
              if (i < rating.floor()) {
                return const Icon(Icons.star,
                    color: AppColors.starFilled, size: 10);
              } else if (i < rating.ceil() && rating % 1 > 0) {
                return const Icon(Icons.star_half,
                    color: AppColors.starFilled, size: 10);
              }
              return const Icon(Icons.star_outline,
                  color: AppColors.starEmpty, size: 10);
            }),
          ),
        ],
      ),
    );
  }

  Widget _posterPlaceholder() {
    // Deterministic gradient based on title
    final hash = item.title.hashCode;
    final hue = (hash % 360).abs().toDouble();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HSLColor.fromAHSL(1.0, hue, 0.12, 0.22).toColor(),
            HSLColor.fromAHSL(1.0, hue, 0.08, 0.10).toColor(),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          color: Colors.white.withValues(alpha: 0.12),
          size: 30,
        ),
      ),
    );
  }
}
