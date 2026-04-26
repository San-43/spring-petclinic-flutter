/*
 * Copyright 2002-2017 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/link.dart';

import '../navigation/app_routes.dart';
import '../theme/classic_theme.dart';
import 'page_width.dart';

enum ClassicSection { home, owners, veterinarians, petTypes, specialties }

class ClassicScaffold extends StatelessWidget {
  const ClassicScaffold({
    super.key,
    required this.section,
    required this.body,
    required this.title,
    this.floatingActionButton,
    this.showPageTitle = true,
    this.showFooter = true,
  });

  final ClassicSection section;
  final Widget body;
  final String title;
  final Widget? floatingActionButton;
  final bool showPageTitle;
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isWide = screenSize.width >= 900;
    final isShort = screenSize.height < 520;
    final bodyVerticalPadding = isShort ? 8.0 : 24.0;
    final titleSpacing = isShort ? 12.0 : 20.0;
    final showFooterInLayout = showFooter && (isWide || !isShort);

    return Scaffold(
      appBar: isWide ? null : const _MobileTopBar(),
      drawer: isWide ? null : _ClassicDrawer(section: section),
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          if (isWide) _WideTopBar(section: section),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                bodyVerticalPadding,
                16,
                bodyVerticalPadding,
              ),
              child: AppPageWidth(
                maxWidth: 1180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showPageTitle) ...[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: titleSpacing),
                    ],
                    Expanded(child: body),
                  ],
                ),
              ),
            ),
          ),
          if (showFooterInLayout) const _ClassicFooter(),
        ],
      ),
    );
  }
}

class _MobileTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _MobileTopBar();

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 66,
      titleSpacing: 16,
      title: Image.asset(
        'assets/images/spring-logo-dataflow-mobile.png',
        height: 34,
        fit: BoxFit.contain,
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(4),
        child: SizedBox(
          height: 4,
          child: DecoratedBox(
            decoration: BoxDecoration(color: ClassicPalette.accent),
          ),
        ),
      ),
    );
  }
}

class _WideTopBar extends StatelessWidget {
  const _WideTopBar({required this.section});

  final ClassicSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ClassicPalette.navbar,
        border: Border(top: BorderSide(color: ClassicPalette.accent, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          height: 84,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: const _DesktopBrandLogo(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final item in _navItems)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: TextButton.icon(
                            onPressed: () => _navigateTo(context, item.route),
                            icon: Icon(
                              item.icon,
                              size: 16,
                              color: item.section == section
                                  ? ClassicPalette.accent
                                  : Colors.white,
                            ),
                            label: Text(
                              item.label.toUpperCase(),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    color: item.section == section
                                        ? ClassicPalette.accent
                                        : Colors.white,
                                  ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopBrandLogo extends StatelessWidget {
  const _DesktopBrandLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 229,
      height: 46,
      child: FittedBox(
        fit: BoxFit.none,
        alignment: Alignment.topLeft,
        clipBehavior: Clip.hardEdge,
        child: Transform.translate(
          offset: const Offset(-1, -1),
          child: Image(
            image: AssetImage('assets/images/spring-logo-dataflow.png'),
            width: 229,
            height: 94,
            fit: BoxFit.none,
          ),
        ),
      ),
    );
  }
}

class _ClassicDrawer extends StatelessWidget {
  const _ClassicDrawer({required this.section});

  final ClassicSection section;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: ClassicPalette.navbar,
              border: Border(
                top: BorderSide(color: ClassicPalette.accent, width: 4),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/spring-logo-dataflow-mobile.png',
                height: 38,
                fit: BoxFit.contain,
              ),
            ),
          ),
          for (final item in _navItems)
            ListTile(
              leading: Icon(
                item.icon,
                color: item.section == section
                    ? ClassicPalette.accent
                    : ClassicPalette.text,
              ),
              title: Text(
                item.label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontFamily: 'Montserrat'),
              ),
              selected: item.section == section,
              onTap: item.section == section
                  ? () => Navigator.of(context).pop()
                  : () {
                      Navigator.of(context).pop();
                      _navigateTo(context, item.route);
                    },
            ),
        ],
      ),
    );
  }
}

class _ClassicFooter extends StatelessWidget {
  const _ClassicFooter();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        screenSize.height < 520 ? 12 : 24,
      ),
      child: AppPageWidth(
        maxWidth: 1180,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 640;
            final isShort = screenSize.height < 520;
            final footerTextStyle = (isCompact || isShort)
                ? Theme.of(context).textTheme.bodySmall
                : Theme.of(context).textTheme.bodyMedium;
            final logoSpacing = isCompact || isShort ? 12.0 : 20.0;

            return Column(
              children: [
                Link(
                  uri: Uri.parse(
                    'https://github.com/San-43/spring-petclinic-flutter',
                  ),
                  target: LinkTarget.blank,
                  builder: (context, followLink) => InkWell(
                    onTap: followLink,
                    child: Text(
                      'Spring Petclinic Flutter Sample Application',
                      textAlign: TextAlign.center,
                      style: footerTextStyle?.copyWith(
                        color: ClassicPalette.accent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isCompact || isShort ? 10 : 20),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/icon_flutter.png',
                          height: 70,
                        ),
                        SizedBox(width: logoSpacing),
                        Image.asset(
                          'assets/images/spring-pivotal-logo.png',
                          height: 42,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ClassicNavItem {
  const _ClassicNavItem({
    required this.section,
    required this.label,
    required this.route,
    required this.icon,
  });

  final ClassicSection section;
  final String label;
  final String route;
  final IconData icon;
}

const _navItems = <_ClassicNavItem>[
  _ClassicNavItem(
    section: ClassicSection.home,
    label: 'Home',
    route: AppRoutes.home,
    icon: Icons.home,
  ),
  _ClassicNavItem(
    section: ClassicSection.owners,
    label: 'Owners',
    route: AppRoutes.owners,
    icon: Icons.person,
  ),
  _ClassicNavItem(
    section: ClassicSection.veterinarians,
    label: 'Veterinarians',
    route: AppRoutes.veterinarians,
    icon: Icons.school,
  ),
  _ClassicNavItem(
    section: ClassicSection.petTypes,
    label: 'Pet Types',
    route: AppRoutes.petTypes,
    icon: Icons.pets,
  ),
  _ClassicNavItem(
    section: ClassicSection.specialties,
    label: 'Specialties',
    route: AppRoutes.specialties,
    icon: Icons.list,
  ),
];

void _navigateTo(BuildContext context, String routeName) {
  if (GoRouterState.of(context).uri.path == routeName) {
    return;
  }
  context.go(routeName);
}
