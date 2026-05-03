import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionDisplay extends StatelessWidget {
  const AppVersionDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final info = snapshot.data!;
          // Displays: 1.0.0 (Build 2)
          return Opacity(
            opacity: 0.6,
            child: Text(
              'v${info.version}+${info.buildNumber}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        return const Text('...', style: TextStyle(fontSize: 10));
      },
    );
  }
}
