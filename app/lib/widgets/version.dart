import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class CurrentVersionText extends StatelessWidget
{
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return Text('version ' + (snapshot.data.version ?? '') + '-' + (snapshot.data.buildNumber ?? ''), style: TextStyle(color: Colors.grey[400], fontSize: 12, decoration: TextDecoration.none));
        } else {
          return Text('');
        }
      }
    );
  }
}