import 'package:flutter/material.dart';
import 'package:planck/constants/types_constant.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/models/company_model.dart';
import 'package:planck/src/screens/store/store_screen.dart';
import 'package:planck/src/screens/taxi/taxi_screen.dart';
import 'package:planck/src/widgets/catalog_image.dart';
import 'package:planck/src/widgets/confirmation_dialog.dart';

class ListCompany extends StatelessWidget {
  const ListCompany(this.companies, {super.key});
  final List<CompanyModel> companies;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width * .76).clamp(244.0, 340.0);
    final scaler = MediaQuery.textScalerOf(context);
    return SizedBox(
      height:
          width * .52 + 44 + scaler.scale(16) * 2.6 + scaler.scale(13) * 2.8,
      child: ListView.separated(
        key: const PageStorageKey('catalog-restaurant-carousel'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: companies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, index) =>
            SizedBox(width: width, child: RestaurantCard(companies[index])),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard(this.company, {super.key});
  final CompanyModel company;

  void _open(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => company.type == TypesCompany.taxi
          ? TaxiScreen(company)
          : StoreScreen(company),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), s = S.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('restaurant-${company.storeId}'),
        onTap: () {
          if (company.isOpen) {
            _open(context);
            return;
          }
          showDialog(
            context: context,
            builder: (_) => ConfirmationDialog(
              s.mDStoreClosed,
              labelOk: s.bAccept,
              iconOk: const Icon(Icons.visibility_outlined),
              onPressedOk: () => _open(context),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1 / .52,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CatalogImage(image: company.image, restaurant: true),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 7,
                              color: company.isOpen
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              company.isOpen ? s.openStore : s.lClosed,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          company.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    company.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (company.open.length >= 5 &&
                      company.close.length >= 5) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 14),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '${company.open.substring(0, 5)} – ${company.close.substring(0, 5)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
