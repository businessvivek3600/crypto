// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '/providers/auth_provider.dart';
import '/widgets/MultiStageButton.dart';
import '../../utils/color.dart';
import '/utils/default_logger.dart';
import 'package:provider/provider.dart';
import '../../repo_injection.dart';
import '../../utils/loader.dart';
import '/route_management/route_name.dart';
import '/screens/BottomNav/dash_setting_page.dart';
import '/utils/sized_utils.dart';
import '/utils/text.dart';

import '../../widgets/FadeScaleTransitionWidget.dart';

class CreateUserName extends StatefulWidget {
  const CreateUserName({super.key});

  @override
  State<CreateUserName> createState() => _CreateUserNameState();
}

class _CreateUserNameState extends State<CreateUserName> {
  AuthProvider provider = sl.get<AuthProvider>();
  TextEditingController name = TextEditingController();
  TextEditingController refCode = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (provider.user.username != null) {
        name.text = provider.user.username!;
      }
      setState(() {});
    });
  }

  String? nameValidator(String? val) {
    RegExp pattern = RegExp(r'^[a-zA-Z0-9_]*$');
    if (val != null) {
      bool hasMatch = pattern.hasMatch(val.trim());
      if (!hasMatch) {
        return 'Username should contain only alphanumeric,_.';
      }
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Container(
        decoration: BoxDecoration(gradient: globalPageGradient()),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            title: bodyLargeText('Profile Setup', context, color: Colors.white),
            actions: [
              TextButton(
                  onPressed: () {
                    context.goNamed(RouteName.home);
                  },
                  child: bodyLargeText('Skip', context, color: Colors.white)),
              const ToggleBrightnessButton()
            ],
          ),
          body: Consumer<AuthProvider>(
            builder: (context, provider, child) {
              return Container(
                padding:
                    EdgeInsetsDirectional.symmetric(horizontal: spaceDefault),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyCustomAnimatedWidget(
                        child: headLineText6("Pick your username", context,
                            color: Colors.white),
                      ),
                      height10(),
                      MyCustomAnimatedWidget(
                        child: bodyLargeText(
                            "This is how other wallet users can find you and send you payments.",
                            context,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                            opacity: 0.3),
                      ),
                      height20(),
                      MyCustomAnimatedWidget(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: TextFormField(
                            controller: name,
                            autovalidateMode: AutovalidateMode.always,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              prefix: Text('   '),
                              hintText: 'Enter user name',
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                            ),
                            validator: nameValidator,
                            onChanged: (val) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      height20(),
                      MyCustomAnimatedWidget(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: TextFormField(
                            controller: refCode,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              prefix: Text('   '),
                              hintText: 'Referral Code',
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),

                      //TODO: privacy setup
                      const Spacer(),
                      MyCustomAnimatedWidget(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            height20(),
                            Padding(
                              padding: EdgeInsets.all(spaceDefault),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: FilledButton(
                                        style: FilledButton.styleFrom(
                                            backgroundColor:
                                                getTheme.colorScheme.primary),
                                        onPressed: provider.updatingProfile !=
                                                    ButtonLoadingState
                                                        .loading &&
                                                name.text.isNotEmpty
                                            ? () async {
                                                primaryFocus?.unfocus();
                                                infoLog((_formKey.currentState
                                                        ?.validate())
                                                    .toString());
                                                if (_formKey.currentState
                                                        ?.validate() ??
                                                    false) {
                                                  setState(() {});
                                                  // provider.updateUserName(
                                                  //     name.text.trim(),
                                                  //     refCode.text.trim(),
                                                  //     context);
                                                  context
                                                      .goNamed(RouteName.home);
                                                }
                                              }
                                            : null,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            bodyLargeText('Confirm', context,
                                                color: Colors.white),
                                            if (provider.updatingProfile ==
                                                ButtonLoadingState.loading)
                                              Row(
                                                children: [
                                                  width10(),
                                                  loaderWidget(radius: 8),
                                                ],
                                              )
                                          ],
                                        )),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      height20(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
