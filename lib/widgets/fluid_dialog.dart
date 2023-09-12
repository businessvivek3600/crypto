import 'package:animations/animations.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';

const String placeholder = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Scripta periculis ei eam, te pro movet reformidans. Eos verear percipit ex, eos ne eligendi inimicus. Pri posse graeco definitiones cu, id eam populo quaestio adipiscing, usu quod malorum te. Offendit eleifend moderatius ex vix, quem odio mazim et qui, purto expetendis cotidieque quo cu, veri persius vituperata ei nec. Pri viderer tamquam ei. Partiendo adversarium no mea. Offendit eleifend moderatius ex vix, quem odio mazim et qui, purto expetendis cotidieque quo cu, veri persius vituperata ei nec. No vis iuvaret appareat. Scripta periculis ei eam, te pro movet reformidans. Scripta periculis ei eam, te pro movet reformidans. Offendit eleifend moderatius ex vix, quem odio mazim et qui, purto expetendis cotidieque quo cu, veri persius vituperata ei nec. Ad doctus gubergren duo, mel te postea suavitate. Liber nusquam insolens has ei, appetere accusamus intellegam id ius.
''';

class _HomePage extends StatelessWidget {
  const _HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: OutlinedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => FluidDialog(
                rootPage: FluidDialogPage(
                  alignment: Alignment.bottomLeft,
                  builder: (context) => const _TestDialog(),
                ),
              ),
            );
          },
          child: const Text('Open Dialog'),
        ),
      ),
    );
  }
}

class _TestDialog extends StatelessWidget {
  const _TestDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hello there',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Text(
              'This is a dialog. It can transition in from the top, bottom, left, or right. The size is also animated.'),
          TextButton(
            onPressed: () => DialogNavigator.of(context).push(
              FluidDialogPage(
                builder: (context) => const _SecondDialogPage(),
              ),
            ),
            child: const Text('Go to next page'),
          ),
        ],
      ),
    );
  }
}

class _SecondDialogPage extends StatelessWidget {
  const _SecondDialogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'And a bigger dialog',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text(placeholder),
            TextButton(
              onPressed: () => DialogNavigator.of(context).pop(),
              child: const Text('Go back'),
            ),
            TextButton(
              onPressed: () => DialogNavigator.of(context).close(),
              child: const Text('Close the dialog'),
            ),
          ],
        ),
      ),
    );
  }
}

class FluidDialogTestPage extends StatelessWidget {
  const FluidDialogTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo'),
        actions: [
          IconButton(
            onPressed: () {
              // The `showModal` function from the animations package is used instead of showDialog
              // because it has a cooler animation.
              showModal(
                context: context,
                builder: (context) => FluidDialog(
                  // Use a custom curve for the alignment transition
                  alignmentCurve: Curves.easeInOutCubicEmphasized,
                  // Setting custom durations for all animations.
                  sizeDuration: const Duration(milliseconds: 300),
                  alignmentDuration: const Duration(milliseconds: 600),
                  transitionDuration: const Duration(milliseconds: 300),
                  reverseTransitionDuration: const Duration(milliseconds: 50),
                  // Here we use another animation from the animations package instead of the default one.
                  transitionBuilder: (child, animation) =>
                      FadeScaleTransition(animation: animation, child: child),
                  // Configuring how the dialog looks.
                  defaultDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  // Setting the first dialog page.
                  rootPage: FluidDialogPage(
                    alignment: Alignment.topRight,
                    builder: (context) => const _InfoDialog(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.all(16.0),
        child: ListView(
          children: const [
            Placeholder(),
            Text(placeholder),
          ],
        ),
      ),
    );
  }
}

/// A simple example of a dialog
class _InfoDialog extends StatelessWidget {
  const _InfoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Style'),
              leading: const Icon(Icons.color_lens_outlined),
              iconColor: Theme.of(context).colorScheme.onSurface,
            ),
            ListTile(
              title: const Text('Format'),
              leading: const Icon(Icons.text_format_rounded),
              iconColor: Theme.of(context).colorScheme.onSurface,
              // Transform to the next dialog when this is pressed.
              onTap: () => DialogNavigator.of(context).push(
                FluidDialogPage(
                  alignment: Alignment.topLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Colors.white,
                  ),
                  builder: (context) => const _FormatPage(),
                ),
              ),
            ),
            ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings_outlined),
              iconColor: Theme.of(context).colorScheme.onSurface,
            ),
            ListTile(
              title: const Text('About'),
              leading: const Icon(Icons.info_outline),
              iconColor: Theme.of(context).colorScheme.onSurface,
              onTap: () => DialogNavigator.of(context).push(
                FluidDialogPage(
                  // This dialog is shown in the center of the screen.
                  alignment: Alignment.center,
                  // Using a custom decoration for this dialog.
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  builder: (context) => const _AboutPage(),
                ),
              ),
            ),
            const Divider(),
            const Text('Words: 420'),
            const Text('Reading Time: 6min 9s'),
          ],
        ),
      ),
    );
  }
}

class _FormatPage extends StatelessWidget {
  const _FormatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 800,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              // Go back to the previous page when the back button is pressed.
              onPressed: () => DialogNavigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).colorScheme.onSurface,
            ),
            ListTile(
              title: Text(
                'Format',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: const Text('Change the format of the page.'),
            ),
            SwitchListTile(
              value: true,
              title: const Text('Enable Something'),
              onChanged: (val) {},
            ),
            SwitchListTile(
              value: false,
              title: const Text('Enable another thing'),
              onChanged: (val) {},
            ),
            const Divider(),
            ListTile(
              title: const Text('Alignment'),
              leading: const Icon(Icons.format_align_left_outlined),
              iconColor: Theme.of(context).colorScheme.onSurface,
            ),
            ListTile(
              title: const Text('Color'),
              leading: const Icon(Icons.format_color_fill_outlined),
              iconColor: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => DialogNavigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                IconButton(
                  // Close the dialog completely.
                  onPressed: () => DialogNavigator.of(context).close(),
                  icon: const Icon(Icons.close),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
            Text(
              'Fluid Dialog Demo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text(placeholder)
          ],
        ),
      ),
    );
  }
}
