import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eclipse/main.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyApp()));
    });
  }

  @override
  void dispose(){
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF1E1B22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Image(
                  image: AssetImage('lib/sources/logomain.jpg'),
                  height: 330,
                  width: 330,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image(
                    image: AssetImage('lib/sources/insgclogo.png'),
                    height: 65,
                  ),
                  Image(
                    image: AssetImage('lib/sources/nsflogo.png'),
                    height: 80,
                  ),
                  Image(
                    image: AssetImage('lib/sources/luddylogo.png'),
                    height: 65,
                  ),
                  Image(
                    image: AssetImage('lib/sources/iulogo.jpg'),
                    height: 65,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}