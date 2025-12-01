import 'package:efinfo_beta/additional/custom_code.dart';
import 'package:efinfo_beta/additional/theme_code.dart';
import 'package:efinfo_beta/library/highlightview.dart';
import 'package:flutter/material.dart';
import 'package:selectable/selectable.dart';

class CodeViewer extends StatelessWidget {
  final String path;
  final String title;
  const CodeViewer({super.key, required this.path, required this.title});

  @override
  Widget build(BuildContext context) {
    return showWidget(context, path, title);
  }
}

Widget _getCodeView(String codeContent, BuildContext context) {
  codeContent = codeContent.replaceAll('\r\n', '\n');
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Selectable(
      child: SizedBox(
        child: HighlightView(
          padding: const EdgeInsets.all(10),
          codeContent,
          language: 'dart',
          theme: atomOneDarkTheme,
        ),
      ),
    ),
  );
}

showWidget(
  BuildContext context,
  String path,
  String title,
) {
  if (path.startsWith("lib/codes/")) {
    return FutureBuilder(
        future: DefaultAssetBundle.of(context).loadString(path),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return CustomCode(
              code: title,
              child: _getCodeView(snapshot.data!, context),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  } else {
    return CustomCode(
      code: title,
      child: _getCodeView(path, context),
    );
  }
}
