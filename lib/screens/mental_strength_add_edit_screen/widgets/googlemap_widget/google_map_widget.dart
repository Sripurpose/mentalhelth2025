import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../home_screen/provider/home_provider.dart';
import '../../provider/mental_strenght_edit_provider.dart';

class MentalGoogleMap extends StatefulWidget {
  final bool edit;

  const MentalGoogleMap({super.key, required this.edit});

  @override
  _MentalGoogleMapState createState() => _MentalGoogleMapState();
}

class _MentalGoogleMapState extends State<MentalGoogleMap> {
  PermissionStatus permissionStatus = PermissionStatus.denied;
  Position? _currentLocation;
  late HomeProvider homeProvider;
  double? savedLatitude = 0.0;
  double? savedLongitude = 0.0;
  String? savedLocationAddress = '';
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);

    if (widget.edit) {
      savedLatitude = double.parse(homeProvider.journalDetails?.journals?.location?.locationLatitude ?? "0.0");
      savedLongitude = double.parse(homeProvider.journalDetails?.journals?.location?.locationLongitude ?? "0.0");
      savedLocationAddress = homeProvider.journalDetails?.journals?.location?.locationAddress ?? "";
      logger.w("savedLatitude: $savedLatitude");
      logger.w("savedLongitude: $savedLongitude");

      if (savedLatitude != 0.0 && savedLongitude != 0.0) {
        _selectedLocation = LatLng(savedLatitude!, savedLongitude!);
        _updateMarkerPosition();
      } else {
        _fetchCurrentLocation();
      }
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
        if (!widget.edit || (savedLatitude == 0.0 && savedLongitude == 0.0)) {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _updateMarkerPosition();
        }
      });

      // Move camera only if no saved location exists
      if (!widget.edit || (savedLatitude == 0.0 && savedLongitude == 0.0)) {
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
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected-location'),
          position: _selectedLocation,
          draggable: true,
          onDragEnd: _onMarkerDragEnd,
        ),
      );
    });
  }

  final Set<Marker> _markers = {};

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
                  imagePath: ImageConstant.imgClosePrimaryNew,
                  height: 40,
                  width: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              onTap: _onMapTapped,
              initialCameraPosition: CameraPosition(
                target: (widget.edit && savedLatitude != 0.0 && savedLongitude != 0.0)
                    ? LatLng(savedLatitude!, savedLongitude!)  // Use saved location when editing
                    : (_currentLocation != null
                    ? LatLng(_currentLocation!.latitude, _currentLocation!.longitude)  // Use current location
                    : const LatLng(0.0, 0.0)), // Fallback before fetching
                zoom: 15.0,
              ),
              markers: _markers,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              tiltGesturesEnabled: true,
              rotateGesturesEnabled: true,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Selected Address: ${_selectedAddress.isNotEmpty ? _selectedAddress : (widget.edit ? savedLocationAddress : "Location not available")}',
            ),
          ),
        ],
      ),
    );
  }

  void _onMapTapped(LatLng location) async {
    MentalStrengthEditProvider mentalStrengthEditProvider =
    Provider.of<MentalStrengthEditProvider>(context, listen: false);
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
          mentalStrengthEditProvider.addLocationSection(
              selectedAddress: _selectedAddress,
              placemark: placemark,
              location: location);
        });
      }
      _updateMarkerPosition();
    } catch (e) {}
  }

  void _onMarkerDragEnd(LatLng location) {
    _onMapTapped(location);
  }
}
