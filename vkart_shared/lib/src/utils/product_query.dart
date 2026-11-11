import '../models/product_model.dart';

/// Quick filters shown as chips above product lists.
enum ProductFilter {
  discount,
  newest,
  bestSeller,
  trending,
}

extension ProductFilterLabel on ProductFilter {
  String get label => switch (this) {
        ProductFilter.discount => 'Discount',
        ProductFilter.newest => 'Newest',
        ProductFilter.bestSeller => 'Best Seller',
        ProductFilter.trending => 'Trending',
      };
}

/// Sort orders offered in the sort sheet.
enum ProductSort {
  newest,
  oldest,
  priceLowToHigh,
  priceHighToLow,
  name,
  discount,
  popularity,
}

extension ProductSortLabel on ProductSort {
  String get label => switch (this) {
        ProductSort.newest => 'Newest',
        ProductSort.oldest => 'Oldest',
        ProductSort.priceLowToHigh => 'Price: Low → High',
        ProductSort.priceHighToLow => 'Price: High → Low',
        ProductSort.name => 'Name (A–Z)',
        ProductSort.discount => 'Discount',
        ProductSort.popularity => 'Popularity',
      };
}

/// Immutable filter/sort state applied to a product list.
///
/// Pure Dart (no Flutter imports) so it can be unit-tested and reused by any
/// screen. Screens hold one of these in local state and call [apply].
class ProductQuery {
  const ProductQuery({
    this.category,
    this.brand,
    this.filters = const {},
    this.sort,
  });

  /// Restrict to one category (case-insensitive), null = all.
  final String? category;

  /// Restrict to one brand (case-insensitive), null = all.
  final String? brand;

  /// Active quick filters; a product must satisfy ALL of them.
  final Set<ProductFilter> filters;

  /// Active sort order; null keeps catalogue order.
  final ProductSort? sort;

  bool get isDefault =>
      category == null && brand == null && filters.isEmpty && sort == null;

  ProductQuery copyWith({
    String? Function()? category,
    String? Function()? brand,
    Set<ProductFilter>? filters,
    ProductSort? Function()? sort,
  }) {
    return ProductQuery(
      category: category != null ? category() : this.category,
      brand: brand != null ? brand() : this.brand,
      filters: filters ?? this.filters,
      sort: sort != null ? sort() : this.sort,
    );
  }

  ProductQuery toggleFilter(ProductFilter filter) {
    final next = Set<ProductFilter>.from(filters);
    if (!next.remove(filter)) next.add(filter);
    return copyWith(filters: next);
  }

  /// "Newest" as a chip needs a cutoff; with no createdAt data the flag
  /// falls back to the admin's newArrival marker.
  static bool _isNew(ProductModel p) {
    if (p.newArrival) return true;
    if (p.createdAtMs <= 0) return false;
    final cutoff =
        DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    return p.createdAtMs >= cutoff;
  }

  bool _matches(ProductModel p) {
    if (category != null &&
        p.category.trim().toLowerCase() != category!.trim().toLowerCase()) {
      return false;
    }
    if (brand != null &&
        p.brand.trim().toLowerCase() != brand!.trim().toLowerCase()) {
      return false;
    }
    for (final filter in filters) {
      final ok = switch (filter) {
        ProductFilter.discount => p.hasDiscount,
        ProductFilter.newest => _isNew(p),
        ProductFilter.bestSeller => p.bestSeller,
        ProductFilter.trending => p.trending,
      };
      if (!ok) return false;
    }
    return true;
  }

  /// Filters then sorts [products] into a new list (input never mutated).
  List<ProductModel> apply(List<ProductModel> products) {
    final result = products.where(_matches).toList();

    switch (sort) {
      case null:
        break;
      case ProductSort.newest:
        result.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
      case ProductSort.oldest:
        result.sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));
      case ProductSort.priceLowToHigh:
        result.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHighToLow:
        result.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.name:
        result.sort((a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case ProductSort.discount:
        result.sort(
            (a, b) => b.discountPercentage.compareTo(a.discountPercentage));
      case ProductSort.popularity:
        // Popularity score first; rating count as a tiebreaker until the
        // store writes real popularity data.
        result.sort((a, b) {
          final byScore = b.popularity.compareTo(a.popularity);
          if (byScore != 0) return byScore;
          return b.ratingCount.compareTo(a.ratingCount);
        });
    }
    return result;
  }

  /// Distinct brands present in [products], preserving first-seen order.
  /// Feeds the brand filter chips — fully data-driven, nothing hardcoded.
  static List<String> brandsOf(List<ProductModel> products) {
    final seen = <String>{};
    final brands = <String>[];
    for (final p in products) {
      final brand = p.brand.trim();
      if (brand.isEmpty) continue;
      if (seen.add(brand.toLowerCase())) brands.add(brand);
    }
    return brands;
  }
}
