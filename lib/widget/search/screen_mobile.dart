import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/constants/sizes.dart';
import 'package:tripitaka91/widget/search/data_search_widget.dart';

class SearchMobileScreen extends StatefulWidget {
  final bool online;

  const SearchMobileScreen({
    super.key,
    required this.online,
  });

  @override
  State<SearchMobileScreen> createState() => _SearchMobileScreenState();
}

class _SearchMobileScreenState extends State<SearchMobileScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        GestureDetector(
          onTap: () {
            showSearch(
              context: context,
              delegate: DataSearch(
                isM: true,
                online: widget.online,
              ),
            );
          },
          child: Container(
            height: 42,
            width: screenWidth - 20,
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            decoration: BoxDecoration(
              border: Border.all(color: TColors.grey),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
              color: TColors.textWhite,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(width: 10),
                const Icon(
                  Icons.search,
                  color: TColors.black,
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Text(
                  'ค้นหา...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
