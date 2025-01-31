import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:instrubuy/admin/adminPanel.dart';
import 'package:instrubuy/admin/productOptionScreen.dart';
import 'package:instrubuy/admin/updateProduct.dart';
import 'package:instrubuy/buttons/roundedIconButton.dart';
import 'package:instrubuy/smallComponents/constants.dart';
import 'package:instrubuy/smallComponents/sizeConfiguration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAllProducts extends StatefulWidget {
  static const String id = "adminAllProducts.dart";

  @override
  _AdminAllProductsState createState() => _AdminAllProductsState();
}

class _AdminAllProductsState extends State<AdminAllProducts> {
  SharedPreferences preferences;
  String productImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initial();
  }

  // For passing customer's profile image.
  void initial() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      productImage = preferences.getString('productImage');
    });
  }

  Future fetchProductData() async {
    var url =
        'https://instrubuy.000webhostapp.com/instrubuy_adminPanel/fetchProducts.php';
    var response = await http.get(url);
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Musical Instruments',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(5),
              vertical: getProportionateScreenWidth(2),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 6, top: 2),
              child: RoundedIconButton(
                iconData: Icons.arrow_back_ios,
                press: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProductOptionScreen()));
                },
              ),
            ),
          ),
        ),
        body: FutureBuilder(
          future: fetchProductData(),
          // snapshot is a library that implements data classes. It simplifies accessing and converting properties in a JSON-like object.
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);
            return snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      List list = snapshot.data;
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.defaultSize,
                            horizontal: SizeConfig.defaultSize * 2),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.blue]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: SizeConfig.defaultSize,
                                horizontal: SizeConfig.defaultSize),
                            leading: CachedNetworkImage(
                              width: SizeConfig.defaultSize * 6,
                              imageUrl:
                                  "https://instrubuy.000webhostapp.com/instrubuy_images/${list[index]['image_location']}",
                              placeholder: (context, url) => Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: SizeConfig.defaultSize * 1.2),
                                child: new CircularProgressIndicator(
                                  color: kPrimaryColor,
                                  backgroundColor: kPrimaryLightColor,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  new Icon(Icons.error),
                            ),
                            title: Text(list[index]['title'],
                                style: TextStyle(color: Colors.white)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: SizeConfig.defaultSize / 2,
                                ),
                                Text("Product ID: " + list[index]['product_id'],
                                    style: TextStyle(color: Colors.white)),
                                Text("Amount: Rs. " + list[index]['price'],
                                    style: TextStyle(color: Colors.white)),
                                Text(
                                    "Quantity: " +
                                        list[index]['product_quantity'],
                                    style: TextStyle(color: Colors.white)),
                                Text("Category: " + list[index]['category_id'],
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateProduct(
                                                  list: list,
                                                  index: index,
                                                )));
                                    debugPrint('Edit button clicked');
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: GestureDetector(
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    onTap: () async {
                                      var url =
                                          "https://instrubuy.000webhostapp.com/instrubuy_adminPanel/deleteActiveProduct.php";
                                      var res = await http.post(url, body: {
                                        'product_id': list[index]['product_id'],
                                      });
                                      if (jsonDecode(res.body) == "true") {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Product has been deleted successfully.",
                                            toastLength: Toast.LENGTH_LONG);
                                      } else if (jsonDecode(res.body) ==
                                          "false") {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Sorry, product could not be deleted.",
                                            toastLength: Toast.LENGTH_LONG);
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Error, please try again later",
                                            toastLength: Toast.LENGTH_SHORT);
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
