import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:flutter_switch/flutter_switch.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool status1 = true;
  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 75, 68, 107),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Weather App",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              Icon(
                Icons.search,
                color: Colors.white,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 20),
                child: Icon(
                  Icons.my_location_outlined,
                  color: Colors.white,
                ),
              )
            ],
          ),
          body: weatherMap != null
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FlutterSwitch(
                                showOnOff: true,
                                activeTextColor: Colors.black,
                                activeText: "C",
                                inactiveTextColor: Colors.blue,
                                inactiveText: "F",
                                value: status1,
                                onToggle: (val) {
                                  setState(() {
                                    status1 = val;
                                  });
                                },
                              ),
                            ],
                          ),
                          Align(
                              alignment: Alignment.centerRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${Jiffy(DateTime.now()).format("MMM do yy")}, ${Jiffy(DateTime.now()).format("h:mm")}",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                  Text(
                                    "${weatherMap!["name"]}",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ],
                              )),
                          Center(
                            child: Column(
                              children: [
                                Image.asset(
                                  "images/2.png",
                                  height: 70,
                                  width: 80,
                                ),
                                Text(
                                  "${forecastMap!["list"][0]["main"]["temp"]}°",
                                  style: TextStyle(
                                      fontSize: 50, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Feeles like ${forecastMap!["list"][0]["main"]["feels_like"]}°",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                Text(
                                  "${forecastMap!["list"][0]["weather"][0]["description"]}",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  "Humidity :${forecastMap!["list"][0]["main"]["humidity"]}, Pressure ${forecastMap!["list"][0]["main"]["pressure"]}",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                Text(
                                  "Sunset ${Jiffy("${DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)}").format("h:mm:a")}, Sunrise ${Jiffy("${DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)}").format("h:mm:a")}",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 200,
                            width: double.infinity,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: forecastMap!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 90,
                                  margin: EdgeInsets.only(right: 8),
                                  height: double.infinity,
                                  color: Color.fromARGB(255, 83, 94, 100),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          "${Jiffy(forecastMap!["list"][index]["dt_txt"]).format("EEE, h:mm")}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                        Image.asset(
                                          "images/3.png",
                                          height: 80,
                                          width: 80,
                                        ),
                                        Text(
                                          "${forecastMap!["list"][index]["main"]["temp_min"]}/${forecastMap!["list"][index]["main"]["temp_max"]}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          "${forecastMap!["list"][index]["weather"][0]["description"]}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white),
                                        ),
                                      ]),
                                );
                              },
                            ),
                          )
                        ]),
                  ),
                )
              : Center(child: CircularProgressIndicator()),
          backgroundColor: Color.fromARGB(151, 79, 84, 101)),
    );
  }

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position = await Geolocator.getCurrentPosition();
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    fetchWeatherData();

    print("Out latitude is $latitude and longitude is $longitude");
  }

  fetchWeatherData() async {
    var weatherResponce = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&exclude=hourly%2Cdaily&appid=cc93193086a048993d938d8583ede38a&fbclid=IwAR1rg9BHqDzqxJia8bplKeuzaNLUVMWNCsfmGjp1-IHI0hpsrGe7Hnq5FMI"));
    var forecastResponce = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=metric&appid=cc93193086a048993d938d8583ede38a&fbclid=IwAR3Hr9_sSo-ju9Us4-W-MpsVaeQyp10SZvo84iTiJ7WjrqTNSkbxRURH5RQ"));
    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponce.body));
      forecastMap =
          Map<String, dynamic>.from(jsonDecode(forecastResponce.body));
    });
    print("ssssssssssssssssssssss${weatherResponce.body}");
  }

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  late Position position;
  double? latitude, longitude;
}
