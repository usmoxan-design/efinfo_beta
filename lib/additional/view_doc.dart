import 'dart:async';
import 'dart:convert';
// import 'dart:io';
import 'dart:ui';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:efinfo_beta/Pages/HomePage.dart';
import 'package:efinfo_beta/additional/codeveiwer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
// import 'package:learn_flutter/pages/other/premium.dart';
import 'package:simple_rich_text/simple_rich_text.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class ViewdocPage extends StatefulWidget {
  ViewdocPage(
      {super.key,
      required this.jsonDataString,
      required this.index,
      required this.title,
      required this.sourceLink,
      required this.isPremium});
  final String jsonDataString;
  final int index;
  final String title;
  String sourceLink;
  bool isPremium;

  @override
  State<ViewdocPage> createState() => _ViewdocPageState();
}

class _ViewdocPageState extends State<ViewdocPage> {
  var _items;

  deleteFileSync() async {
    String fileName =
        "${widget.jsonDataString.toLowerCase().trim().replaceAll(" ", "").replaceAll(",", "").replaceAll("-", "").replaceAll("&", "")}${widget.index}.json";
    var dir = await getExternalStorageDirectory();
    // var dir = await getTemporaryDirectory();

    File file = File("${dir!.path}/$fileName");
    file.deleteSync();
  }

  Future<List<dynamic>> fetchUsers() async {
    String fileName =
        "${widget.jsonDataString.toLowerCase().trim().replaceAll(" ", "").replaceAll(",", "").replaceAll("-", "").replaceAll("&", "")}${widget.index}.json";

    var dir = await getExternalStorageDirectory();
    // var dir = await getTemporaryDirectory();

    File file = File("${dir!.path}/$fileName");

    if (file.existsSync()) {
      try {
        //  final result = await InternetAddress.lookup(widget.sourceLink);
        //if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var result = await http.get(Uri.parse(widget.sourceLink));
        file.writeAsStringSync(result.body, flush: true, mode: FileMode.write);
        //}
      } on SocketException catch (_) {
        // var result = await http.get(Uri.parse(widget.sourceLink));
        // file.writeAsStringSync(result.body, flush: true, mode: FileMode.write);

        print('error');
      }
      var jsonData = file.readAsStringSync();
      return jsonDecode(jsonData)['items'];
    } else {
      var result = await http.get(Uri.parse(widget.sourceLink));
      file.writeAsStringSync(result.body, flush: true, mode: FileMode.write);
// "https://usmoxan.github.io/testdata.json"
      return jsonDecode(result.body)['items'];
    }
  }

  @override
  void initState() {
    _items = fetchUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      "${widget.jsonDataString.toLowerCase().trim().replaceAll(" ", "").replaceAll(",", "").replaceAll("-", "").replaceAll("&", "")}${widget.index}.json",
                      style: const TextStyle(fontSize: 18),
                    ),
                    duration: const Duration(milliseconds: 1500),
                  ));
                  //deleteFileSync();
                  // readJson("uz");
                },
                icon: const Icon(Ionicons.save_outline))
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.black, fontFamily: "Gotham"),
          ),
        ),
        body: Stack(children: [
          bodyViewDocPage(items: _items),
          getImage(context, widget.isPremium),
          Visibility(
            visible: widget.isPremium,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(15),
                child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ));
                    },
                    child: const Text("Ko'proq o'qish")),
              ),
            ),
          )
        ]));
  }
}

getImage(BuildContext context, bool boolValue) {
  return Visibility(
    visible: boolValue,
    child: Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.98),
            Colors.white.withOpacity(0.98),
            const Color.fromARGB(255, 255, 255, 255)
          ])),
    ),
  );
}

class bodyViewDocPage extends StatelessWidget {
  const bodyViewDocPage({
    super.key,
    required items,
  }) : _items = items;

  final _items;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _items,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        try {
          if (snapshot.hasData) {
            return ListView.builder(
              cacheExtent: 1000,
              addAutomaticKeepAlives: true,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                if (snapshot.data[index]['code'] == "true") {
                  return CodeViewer(
                    path: snapshot.data[index]['code_path']!,
                    title: snapshot.data[index]['title'],
                  );
                } else if (snapshot.data[index]['text_is'] == "true") {
                  return Padding(
                      padding: const EdgeInsets.all(10),
                      child: SimpleRichText(
                        snapshot.data[index]['text'],
                        style: const TextStyle(
                            fontSize: 21,
                            color: Colors.black,
                            fontFamily: "Gotham"),
                      ));
                } else if (snapshot.data[index]['image_is'] == "true") {
                  return CachedNetworkImage(
                    placeholder: (context, url) =>
                        const LinearProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                    imageUrl: snapshot.data[index]['image'],
                  );

                  // return Image.network(snapshot.data[index]['image']);
                } else if (snapshot.data[index]['button_is'] == "true") {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Wrap(
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                Uri url = Uri.parse(
                                    snapshot.data[index]['button_url']);

                                if (!await launchUrl(url,
                                    mode: LaunchMode.externalApplication)) {
                                  throw 'Could not launch';
                                }
                              },
                              child: Text(snapshot.data[index]['button_text'])),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Container();
                }

                // return Text(_items[index]['text']);
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        } catch (e) {
          return const Text("Somer error ");
        }
      },
    );
  }
}
