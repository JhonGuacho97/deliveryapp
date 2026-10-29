import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Reserves the photo's space on slow networks and when no photo is available.
class CatalogImage extends StatelessWidget {
  const CatalogImage({super.key, required this.image, this.restaurant = false});
  final String image;
  final bool restaurant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.surfaceContainerLow],
        ),
      ),
      child: Center(
        child: Icon(
          restaurant ? Icons.storefront_rounded : Icons.restaurant_rounded,
          size: restaurant ? 52 : 40,
          color: scheme.primary.withValues(alpha: .5),
        ),
      ),
    );
    if (image.isEmpty) return placeholder;
    return ExcludeSemantics(
      child: image.startsWith('assets/')
          ? Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            )
          : CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              memCacheWidth: 1200,
              imageBuilder: (context, provider) {
                final scope = GlassContentAwareScope.maybeOf(context);
                if (scope != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) scope.requestSample();
                  });
                }
                return Image(image: provider, fit: BoxFit.cover);
              },
              placeholder: (_, _) => placeholder,
              errorWidget: (_, _, _) => placeholder,
            ),
    );
  }
}
