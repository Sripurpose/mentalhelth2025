import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../home_screen/provider/home_provider.dart';

class JournalGoogleMapWidgets extends StatefulWidget {
  const JournalGoogleMapWidgets(
      {super.key, required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  _JournalGoogleMapWidgetsState createState() => _JournalGoogleMapWidgetsState();
}

class _JournalGoogleMapWidgetsState extends State<JournalGoogleMapWidgets> {
  late HomeProvider homeProvider;
  PermissionStatus permissionStatus = PermissionStatus.denied;
  Position? _currentLocation;
  LatLng _selectedLocation = const LatLng(0, 0);
  String selectedAddress = '';
  final Set<Marker> _markers = {};
  late GoogleMapController mapController;

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    super.initState();
    _checkPermissionStatus();
    _requestPermission();
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

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentLocation = position;

          // Set initial location to the journal location if available, else current location
          _selectedLocation = widget.latitude != 0 && widget.longitude != 0
              ? LatLng(widget.latitude, widget.longitude)
              : LatLng(_currentLocation!.latitude, _currentLocation!.longitude);
        });

        // Update marker and move camera to the selected location
        _updateMarkerPosition();
        mapController.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation, 15.0));
      }
    } catch (e) {
      // Handle location errors
    }
  }

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return _currentLocation == null && widget.latitude == 0
        ?  SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColorsContent.newThemeColor), // Set the desired color here
        ))
        :
      SizedBox(
      height: size.height * 0.3,
      child:  GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(_selectedLocation, 15.0), // Zoom to initial location
          );
        },
        onTap: _onMapTapped,
        initialCameraPosition: CameraPosition(
          target: _selectedLocation, // Focus on the selected location
          zoom: 15.0, // Set initial zoom level
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
      ),
    );
  }

  void _onMapTapped(LatLng location) async {
    setState(() {
      _selectedLocation = location;
    });

    // Update homeProvider journal details with the new location
    homeProvider.journalDetails!.journals!.location!.locationLatitude =
        _selectedLocation.latitude.toString();
    homeProvider.journalDetails!.journals!.location!.locationLongitude =
        _selectedLocation.longitude.toString();

    // Animate the camera to the new location
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_selectedLocation, 15.0), // Move to the new location with zoom
    );

    // Update the marker and the selected address
    _updateMarkerPosition();
    _getAddressFromLatLng(_selectedLocation);
  }

  void _getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          selectedAddress =
          '${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
        });
      }
    } catch (e) {
      showCustomSnackBar(context: context, message: e.toString());
    }
  }

  void _onMarkerDragEnd(LatLng location) {
    _onMapTapped(location);
  }
}

