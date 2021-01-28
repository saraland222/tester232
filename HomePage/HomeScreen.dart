import 'package:appboy/Screen/top_picker_stroe.dart';
import 'package:appboy/providers/auth_provider.dart';
import 'package:appboy/widget/appBar.dart';
import 'package:appboy/widget/image_slider.dart';
import 'package:appboy/widget/nearByStores.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  static const String id = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              MyAppBar()
            ];  
          },
        body: ListView(
          children: [
            ImageSlider(),
            Container(height: 200, child: TopPickerStore()),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: NearByStores(),
            ),
          ],
        ), 
      ),
    );
  }
}
