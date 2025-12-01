import 'package:efinfo_beta/additional/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomCode extends StatelessWidget {
  const CustomCode({super.key, required this.code, required this.child});
  final String code;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: white),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 134, 134, 134),
              blurRadius: 2.0,
              spreadRadius: 0.0,
              offset: Offset(2.0, 2.0), // shadow direction: bottom right
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(13),
            topRight: Radius.circular(13),
            bottomLeft: Radius.circular(13),
          ),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        color: topColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12))),
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 15,
                            width: 15,
                            decoration: const BoxDecoration(
                                color: Color(0xfffc5859),
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            height: 15,
                            width: 15,
                            decoration: const BoxDecoration(
                                color: Color(0xfffebd2f),
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            height: 15,
                            width: 15,
                            decoration: const BoxDecoration(
                                color: Color(0xff37cd42),
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              child: Text(
                            code,
                            style: const TextStyle(fontSize: 18),
                          )),
                          IconButton(
                              onPressed: () async {
                                ClipboardData data = const ClipboardData(
                                    text: '<Text to copy goes here>');
                                await Clipboard.setData(data);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    "Nusxa olindi",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  duration: Duration(milliseconds: 1500),
                                ));
                              },
                              icon: const Icon(Icons.copy_all_rounded))
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: child,
              ),
            ]),
      ),
    );
  }
}
