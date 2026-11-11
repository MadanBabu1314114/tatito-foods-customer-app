/// A local promotional banner shown on the home screen.
class BannerItem {
  const BannerItem({
    required this.id,
    required this.badge,
    required this.title,
    required this.subtitle,
  });

  final int id;
  final String badge;
  final String title;
  final String subtitle;
}
