import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addactions_screen/provider/add_actions_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class AddActionGoogleMap extends StatefulWidget {
  const AddActionGoogleMap({super.key});

  @override
  _AddActionGoogleMapState createState() => _AddActionGoogleMapState();
}

class _AddActionGoogleMapState extends State<AddActionGoogleMap> {
  PermissionStatus permissionStatus = PermissionStatus.denied;
  Position? _currentLocation;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  double? savedLatitude = 0.0;
  double? savedLongitude = 0.0;
  String? savedLocationAddress = '';
  var logger = Logger();
  late GoogleMapController mapController;
  LatLng _selectedLocation = const LatLng(0.0, 0.0);
  String _selectedAddress = '';
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    mentalStrengthEditProvider = Provider.of<MentalStrengthEditProvider>(context, listen: false);
    _initializeLocation();
  }

  void _initializeLocation() async {
    savedLatitude = double.tryParse(mentalStrengthEditProvider.actionsDetailsModel?.actions?.location?.locationLatitude ?? "0.0");
    savedLongitude = double.tryParse(mentalStrengthEditProvider.actionsDetailsModel?.actions?.location?.locationLongitude ?? "0.0");
    savedLocationAddress = mentalStrengthEditProvider.actionsDetailsModel?.actions?.location?.locationAddress ?? "";

    logger.w("Saved Latitude: $savedLatitude");
    logger.w("Saved Longitude: $savedLongitude");

    if (savedLatitude != 0.0 && savedLongitude != 0.0) {
      _selectedLocation = LatLng(savedLatitude!, savedLongitude!);
      _updateMarkerPosition();
    } else {
      await _fetchCurrentLocation();
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

      if (savedLatitude == 0.0 && savedLongitude == 0.0) {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation, 15.0),
        );
      }
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
                target: (savedLatitude != 0.0 && savedLongitude != 0.0)
                    ? LatLng(savedLatitude!, savedLongitude!)  // Use saved location
                    : (_currentLocation != null
                    ? LatLng(_currentLocation!.latitude, _currentLocation!.longitude)  // Use current location
                    : const LatLng(0.0, 0.0)), // Default fallback before fetching
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
              'Selected Address: ${_selectedAddress.isNotEmpty ? _selectedAddress : savedLocationAddress}',
            ),
          ),
        ],
      ),
    );
  }

  void _onMapTapped(LatLng location) async {
    AddActionsProvider addActionsProvider =
    Provider.of<AddActionsProvider>(context, listen: false);
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
          addActionsProvider.addLocationSection(
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
