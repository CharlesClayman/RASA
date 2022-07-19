import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'hotspotPage.dart';

class HotspotListPage extends StatefulWidget{
  @override  
   State<StatefulWidget> createState() => _HotspotListPage();
}

class _HotspotListPage extends State<HotspotListPage>{
    //Hotspot search textfield
  TextEditingController _searchController = TextEditingController();
  Future resultsLoaded;
  List _allResults = [];
  List _resultsList = [];

  @override
    void initState() {
       _searchController.addListener(_onSearchChanged
    );
      super.initState();
    }

     @override
  void dispose() {

    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }


  @override
  void didChangeDependencies() {
    resultsLoaded = getHotspotSnapshots();
    super.didChangeDependencies();
  }


  _onSearchChanged(){
     searchResultsList();
  }

  searchResultsList() {
    var showResults = [];

    if (_searchController.text != "") {
      print(_searchController.text.toString());

      for (var value in _allResults) {
        var title = value["PlaceName"].toString().toLowerCase();

        if (title.contains(_searchController.text.toLowerCase())) {
          showResults.add(value);

          print(showResults[0]["PlaceName"].toString());
        }
      }
    } else {
      showResults = List.from(_allResults);
    }

    setState(() {
      _resultsList = showResults;
    });
  }

   //get hotspot list
  getHotspotSnapshots() async {
    await FirebaseFirestore.instance
        .collection('hotspot_markers')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          _allResults.add(doc);
          print(doc["PlaceName"]);
        });
      });
    });
    searchResultsList();
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                title: Text("List of Hotspot Areas"),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    Color.fromRGBO(26, 21, 0, 0.8),
                    Color.fromRGBO(221, 255, 51, 0.8),
                  ])),
                ),
              ),
      body: Column
                  (
                                            children: [
                                              SizedBox(
                                                height: 1,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.3),
                                         
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: TextField(                                                                                       
                                                        controller:
                                                            _searchController,
                                                        cursorColor:
                                                            Colors.black,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        textInputAction:
                                                            TextInputAction.go,
                                                        decoration: InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            15),
                                                            hintText:
                                                                "Search for hotspot areas..."),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: CircleAvatar(
                                                        child:
                                                            Icon(Icons.search),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),                    

                                              Expanded(
                                                child: hotspotList(),
                                              )  ,  
                                              
                                            ],
                                          ),
    );
  }

   Widget hotspotList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: _resultsList.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(border: Border()),
          child: ListTile(
            leading: Icon(
              FontAwesomeIcons.mapMarked,
              color: Colors.green,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HotspotPage(
                            markerid: _resultsList[index]["PlaceName"],
                            latLng: _resultsList[index]["PlaceLocation"],
                            hotspot_id: _resultsList[index].id,
                          )));
            },
            title: Text(
              _resultsList[index]["PlaceName"],
            ),
          ),
        );
      },
    );
    }

}