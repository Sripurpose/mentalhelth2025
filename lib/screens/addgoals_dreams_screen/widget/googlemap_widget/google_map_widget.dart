import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../goals_dreams_page/model/goals_and_dreams_model.dart';

class AddGoalsGoogleMap extends StatefulWidget {
  const AddGoalsGoogleMap({super.key, this.goalsanddream});
  final Goalsanddream? goalsanddream;

  @override
  _AddGoalsGoogleMapState createState() => _AddGoalsGoogleMapState();
}

class _AddGoalsGoogleMapState extends State<AddGoalsGoogleMap> {
  PermissionStatus permissionStatus = PermissionStatus.denied;
  Position? _currentLocation;
  late AdDreamsGoalsProvider adDreamsGoalsProvider;
  double? savedLatitude = 0.0;
  double? savedLongitude = 0.0;
  String? savedLocationAddress = '';
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    adDreamsGoalsProvider = Provider.of<AdDreamsGoalsProvider>(context, listen: false);

    // Retrieve saved location if available
    savedLatitude = double.parse(widget.goalsanddream?.location?.locationLatitude ?? "0.0");
    savedLongitude = double.parse(widget.goalsanddream?.location?.locationLongitude ?? "0.0");
    savedLocationAddress = widget.goalsanddream?.location?.locationAddress ?? "";

    logger.w("Saved Latitude: $savedLatitude");
    logger.w("Saved Longitude: $savedLongitude");

    if (savedLatitude != 0.0 && savedLongitude != 0.0) {
      _selectedLocation = LatLng(savedLatitude!, savedLongitude!);
      _updateMarkerPosition();
    } else {
      _fetchCurrentLocation();
    }
  }

  Future<void> _fetchCurrentLocation() async {
    await _checkPermissionStatus();
    await _requestPermission();
    _getCurrentLocation();
  }

  Future<void> _checkPermissionStatus() async {
    final status = await Permission.locationWhenInUse.status;
    setState(() {
      permissionStatus = status;
    });
  }

  Future<void> _requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    setState(() {
      permissionStatus = status;
    });
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (mounted) {
      setState(() {
        _currentLocation = position;
        if (savedLatitude == 0.0 && savedLongitude == 0.0) {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _updateMarkerPosition();
        }
      });

      // Move camera only if no saved location exists
      if (savedLatitude == 0.0 && savedLongitude == 0.0) {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation, 15.0),
        );
      }
    }
  }

  late GoogleMapController mapController;
  LatLng _selectedLocation = const LatLng(0, 0);
  String _selectedAddress = '';

  void _updateMarkerPosition() {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('selected-location'),
          position: _selectedLocation,
          draggable: true,
          onDragEnd: _onMarkerDragEnd,
        ),
      );
    });
  }

  final Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.4,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: CustomImageView(
                  imagePath: ImageConstant.imgClosePrimary,
                  height: 40,
                  width: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GoogleMap(
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              onTap: _onMapTapped,
              initialCameraPosition: CameraPosition(
                target: (savedLatitude != 0.0 && savedLongitude != 0.0)
                    ? LatLng(savedLatitude!, savedLongitude!) // Use saved location
                    : (_currentLocation != null
                    ? LatLng(_currentLocation!.latitude, _currentLocation!.longitude) // Use current location
                    : const LatLng(0.0, 0.0)), // Default fallback
                zoom: 15.0,
              ),
              markers: markers,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              tiltGesturesEnabled: true,
              rotateGesturesEnabled: true,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Selected Address: ${_selectedAddress.isNotEmpty ? _selectedAddress : savedLocationAddress}',
            ),
          ),
        ],
      ),
    );
  }

  void _onMapTapped(LatLng location) async {
    AdDreamsGoalsProvider adDreamsGoalsProvider =
    Provider.of<AdDreamsGoalsProvider>(context, listen: false);
    setState(() {
      _selectedLocation = location;
    });

    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          _selectedAddress =
          '${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
          adDreamsGoalsProvider.addLocationSection(
            selectedAddress: _selectedAddress,
            placemark: placemark,
            location: location,
          );
        });
      }
      _updateMarkerPosition();
    } catch (e) {
      logger.e(e.toString());
    }
  }

  void _onMarkerDragEnd(LatLng location) {
    _onMapTapped(location);
  }
}
