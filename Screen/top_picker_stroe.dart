import 'package:appboy/Screen/vendor_home_screen.dart';
import 'package:appboy/providers/store_provider.dart';
import 'package:appboy/services/store_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class TopPickerStore extends StatefulWidget {

  @override
  _TopPickerStoreState createState() => _TopPickerStoreState();
}

class _TopPickerStoreState extends State<TopPickerStore> {

  double latitude = 0.0;
  double longitude = 0.0;


  @override
  void didChangeDependencies() {
    final _storeData = Provider.of<StoreProvider>(context);
    _storeData.determinePosition().then((position){
      latitude = position.latitude;
      longitude = position.longitude;
    });
    super.didChangeDependencies();
  }
  String getDisyance(location) {
    var distance = Geolocator.distanceBetween(
        latitude,
        longitude, location.latitude, location.longitude);
    var distanceInKm = distance / 1000;
    return distanceInKm.toStringAsFixed(2);
  }


  @override
  Widget build(BuildContext context) {

    StoreService storeService = StoreService();
    final _storeData = Provider.of<StoreProvider>(context);
    //_storeData.getUserLocationData(context);



    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: storeService.getTopPickedStore(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          //here i need to confirm even no shop bear by not
          List shopDistance = [];
          for (int i = 0; i <= snapshot.data.docs.length - 1; i++) {
            var distance = Geolocator.distanceBetween(
                latitude,
                longitude,
                snapshot.data.docs[i]['loaction'].latitude,
                snapshot.data.docs[i]['loaction'].longitude);
            var distanceInKm = distance / 1000;
            shopDistance.add(distanceInKm);
          }
          shopDistance
              .sort(); ///////this will sort with bearest distance. if nearest distance is more then 10, that means no shop near by;
          if (shopDistance[0] > 10) {
            return Container();
          }
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                   SizedBox(
                     height: 30.0,
                     child: Image.asset('assets/images/marker.png'),
                   ),
                   Text('Top Picked Stores For You')
                  ],
                ),
                Flexible(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        snapshot.data.docs.map((DocumentSnapshot document) {
                      if (double.parse(getDisyance(document['loaction'])) <=
                          10) {
                        //showing the stores only with in 10km
                        return InkWell(
                          onTap: (){
                            _storeData.getSelectedStore(document, getDisyance(document['loaction']));

                            pushNewScreenWithRouteSettings(
                              context,
                              settings: RouteSettings(name: VendorHomeScreen.id),
                              screen: VendorHomeScreen(),
                              withNavBar: true,
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );


                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              width: 80,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 80,
                                        width: 80,
                                        child: Card(
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                                child: Image.network(
                                                  document['imageurl'],
                                                  fit: BoxFit.cover,
                                                ))),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 35,
                                    child: Text(
                                      document['shopName'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${getDisyance(document['loaction'])}km',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        //if no stores
                        return Container();
                      }
                    }).toList(),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
