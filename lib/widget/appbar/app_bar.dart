import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/auth/authentication_service.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/constants/sizes.dart';
import 'package:tripitaka91/widget/login/login.dart';
import 'package:tripitaka91/widget/login/member_tab_show.dart';
import 'package:tripitaka91/widget/search/data_search_widget.dart';

class AppBarCustom extends StatefulWidget {
  final bool isTablet;
  final bool isDesktop;
  final bool online;
  const AppBarCustom({
    super.key,
    required this.isTablet,
    required this.isDesktop,
    required this.online,
  });

  @override
  State<AppBarCustom> createState() => _AppBarCustomState();
}

class _AppBarCustomState extends State<AppBarCustom> {
  final AuthenticationService _authService = AuthenticationService();
  bool isLoggedIn = false;
  // Users? _usersData;

  @override
  void initState() {
    super.initState();
    // _getUser();
  }

  Future<void> _checkLoginStatus() async {
    isLoggedIn = await _authService.checkLoginStatus();

    if (isLoggedIn) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const MemberTabShow(indexShow: 0)),
      );
    } else {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  // void _getUser() async {
  //   _usersData = await getUsersList();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/tripitaka91_logo.png',
              fit: BoxFit.cover,
              height: 35,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                showSearch(
                  context: context,
                  delegate:
                      widget.isTablet == false && widget.isDesktop == false
                          ? DataSearch(
                              isM: true,
                              online: widget.online,
                            )
                          : DataSearch(
                              isM: false,
                              online: widget.online,
                            ),
                );
              },
              child: widget.isTablet == false && widget.isDesktop == false
                  ? const SizedBox.shrink()
                  : Container(
                      width: widget.isDesktop ? 580 : 380,
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: TColors.grey),
                        borderRadius:
                            BorderRadius.circular(TSizes.cardRadiusLg),
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
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: _checkLoginStatus,
            ),
          ],
        ),
      ],
    );
  }
}
