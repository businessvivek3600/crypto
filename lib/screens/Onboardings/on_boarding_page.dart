// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/providers/WalletProvider.dart';
import '/utils/default_logger.dart';
import '/utils/loader.dart';
import '/widgets/MultiStageButton.dart';
import 'package:provider/provider.dart';
import '../../repo_injection.dart';
import '/constants/app_const.dart';
import '/constants/asset_constants.dart';
import '/route_management/route_animation.dart';
import '/route_management/route_name.dart';
import '/utils/picture_utils.dart';
import '/utils/sized_utils.dart';
import '/utils/text.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

bool showOnBoarding = true;

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage>
    with SingleTickerProviderStateMixin {
  late PageController controller;

  @override
  void initState() {
    controller = PageController(initialPage: 0);
    super.initState();
  }

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    List<String> assetName = ['2', '6', '4', '5'];
    List<String> titles = [
      'Secure Your Digital Assets',
      'Trade Like a Pr',
      "Join the Crypto Community",
      'Discover the World of Cryptocurrency'
    ];
    List<String> desc = [
      'Learn how to safeguard your crypto holdings with advanced security measures and best practices in the crypto world.',
      'Master the art of crypto trading with real-time market data, expert insights, and powerful trading tools.',
      'Connect with like-minded individuals, stay updated with crypto news, and participate in discussions that shape the future of finance."',
      'Dive into the exciting realm of digital currencies and explore the endless possibilities of blockchain technology.'
    ];
    double bottomSpace = 30;
    final pages = List.generate(
        4,
        (index) => Column(
              children: [
                height20(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingDefault),
                  child: Column(
                    children: [
                      titleLargeText(titles[index], context,
                          textAlign: TextAlign.center,
                          fontSize: getHeight * 0.04,
                          fontWeight: FontWeight.normal),
                      height20(),
                      bodyLargeText(desc[index], context,
                          textAlign: TextAlign.center,
                          maxLines: 10,
                          fontWeight: FontWeight.w500),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(seconds: 1),
                    child: SizedBox(
                      // height: getWidth,
                      child: assetImages('${assetName[index]}.png'),
                    ),
                  ),
                ),
              ],
            ));
    return Scaffold(
      body: Column(
        children: [
          Column(
            children: [
              height20(),
              SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    assetImages(PNGAssets.appLogo, width: 50),
                    width10(),
                    titleLargeText(AppConst.appName, context, fontSize: 22)
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  // key: widget.pageViewKey,
                  scrollBehavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false,
                    overscroll: false,
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  controller: controller,
                  reverse: false,
                  physics: const ScrollPhysics(),
                  itemCount: 4,
                  pageSnapping: true,
                  onPageChanged: (int page) {
                    setState(() {
                      currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) {
                        // final progress = controller.page! - index;

                        return pages[index];
                        return child!;
                      },
                    );
                  },
                ),
                //skip
                /* Positioned(
                  bottom: Get.height - 70,
                  right: 20,
                  child: GestureDetector(
                      onTap: () {
                        if (currentPage < pages.length - 1) {
                          controller.animateToPage(pages.length - 1,
                              duration: const Duration(seconds: 1),
                              curve: Curves.fastOutSlowIn);
                          return;
                        }
                        showOnBoarding = false;
                        context.go(RoutePath.login);
                      },
                      child: bodyLargeText(
                          currentPage < pages.length - 1 ? 'Skip' : 'Login',
                          context,
                          color: getTheme.colorScheme.primary)),
                ),*/
                //brightness
                /*
                const Positioned(
                    top: 0, left: 10, child: ToggleBrightnessButton()),
*/
                //next button
                /*  Positioned(
                    bottom:
                        currentPage < pages.length - 1 ? bottomSpace / 2 : 22,
                    right: spaceDefault,
                    child: AnimatedSwitcher(
                      duration: const Duration(
                          milliseconds: 2000), // Animation duration
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: currentPage == pages.length - 1
                          ? SizedBox(
                              // height: 30,
                              child: GestureDetector(
                                  onTap: () {
                                    // showOnBoarding = false;
                                    context.pushNamed(RouteName.login,
                                        queryParameters: {
                                          'anim': RouteTransition.fade.name,
                                          'data': jsonEncode(List.generate(
                                                  12, (index) => 'object$index')
                                              .toList())
                                        });
                                  },
                                  child: bodyLargeText('Import',context,
                                      color: getTheme.colorScheme.primary)))
                          : SizedBox(
                              child: IconButton.filled(
                                  onPressed: () {
                                    if (currentPage < pages.length - 1) {
                                      controller.animateToPage(currentPage + 1,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.fastOutSlowIn);
                                      return;
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_forward,
                                      color: Colors.white)),
                            ),
                    )),
                Positioned(
                    bottom:
                        currentPage < pages.length - 1 ? bottomSpace / 2 : 22,
                    left: spaceDefault,
                    child: AnimatedSwitcher(
                      duration: const Duration(
                          milliseconds: 1000), // Animation duration
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: currentPage == pages.length - 1
                          ? GestureDetector(
                              onTap: () {
                                // showOnBoarding = false;
                                context.pushNamed(RouteName.createNewWallet,
                                    queryParameters: {
                                      'anim': RouteTransition.fade.name,
                                      'data': jsonEncode(List.generate(
                                          12, (index) => 'object$index')
                                          .toList())
                                    });
                              },
                              child: bodyLargeText('New Wallet',context,
                                  color: getTheme.colorScheme.primary))
                          : SizedBox(height: bottomSpace / 2),
                    )),*/
                //indicator
                /*Positioned(
                  bottom: bottomSpace,
                  right: 0,
                  left: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SmoothPageIndicator(
                        controller: controller,
                        count: pages.length,
                        effect: ExpandingDotsEffect(
                          expansionFactor: 1.5,
                          dotColor: Colors.grey[200]!,
                          activeDotColor: getTheme.colorScheme.primary,
                          dotHeight: 12,
                          dotWidth: 12,
                          // paintStyle: PaintingStyle.stroke
                          // type: WormType.thinUnderground,
                        ),
                      ),
                    ],
                  ),
                ),*/
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SmoothPageIndicator(
                controller: controller,
                count: pages.length,
                effect: ExpandingDotsEffect(
                  expansionFactor: 1.5,
                  dotColor: Colors.grey[200]!,
                  activeDotColor: getTheme.colorScheme.primary,
                  dotHeight: 12,
                  dotWidth: 12,
                  // paintStyle: PaintingStyle.stroke
                  // type: WormType.thinUnderground,
                ),
              ),
            ],
          ),
          height20(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 2000), // Animation duration
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: currentPage == pages.length - 1
                ? SizedBox(
                    // height: 30,
                    child: FilledButton(
                        onPressed: () {
                          // showOnBoarding = false;
                          context.pushNamed(RouteName.importWallet,
                              queryParameters: {
                                'anim': RouteTransition.fade.name
                              });
                        },
                        child: bodyLargeText('Import Wallet', context,
                            color: Colors.white)))
                : SizedBox(
                    child: IconButton.filled(
                        onPressed: () {
                          if (currentPage < pages.length - 1) {
                            controller.animateToPage(currentPage + 1,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.fastOutSlowIn);
                            return;
                          }
                        },
                        icon: const Icon(Icons.arrow_forward,
                            color: Colors.white)),
                  ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500), // Animation duration
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: currentPage == pages.length - 1
                ? Consumer<WalletProvider>(
                    builder: (context, provider, child) {
                      return FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.white),
                          onPressed: () async {
                            // showOnBoarding = false;
                            var data = await sl
                                .get<WalletProvider>()
                                .createNewWallet();
                            // infoLog(data.toString());
                            if (data != null) {
                              context.pushNamed(RouteName.createNewWallet,
                                  queryParameters: {
                                    'anim': RouteTransition.fade.name,
                                    'data': jsonEncode(data)
                                  });
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              bodyLargeText('Create New Wallet', context,
                                  color: getTheme.colorScheme.primary),
                              if (provider.creatingMnemonics ==
                                  ButtonLoadingState.loading)
                                Row(
                                  children: [
                                    width10(),
                                    loaderWidget(radius: 7),
                                  ],
                                )
                            ],
                          ));
                    },
                  )
                : const SizedBox(height: 50),
          ),
          height20(),
        ],
      ),
    );
  }
}
