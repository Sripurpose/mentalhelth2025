import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

import '../../../../utils/theme/colors.dart';

class AddActionGoogleMap extends StatefulWidget {
  const AddActionGoogleMap({super.key});

  @override
  _AddActionGoogleMapState createState() => _AddActionGoogleMapState();
}

class _AddActionGoogleMapState extends State<AddActionGoogleMap> {
  PermissionStatus permissionStatus = PermissionStatus.denied;
  Position? _currentLocation;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late AddActionsProvider addActionsProvider;
  double? savedLatitude = 0.0;
  double? savedLongitude = 0.0;
  String? savedLocationAddress = '';
  var logger = Logger();
  late GoogleMapController mapController;
  LatLng _selectedLocation = const LatLng(0.0, 0.0);
  String _selectedAddress = '';
  final Set<Marker> _markers = {};

  // 🔍 Search functionality variables
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResultsWithNames = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    mentalStrengthEditProvider = Provider.of<MentalStrengthEditProvider>(context, listen: false);
    addActionsProvider = Provider.of<AddActionsProvider>(context, listen: false);
    _initializeLocation();
  }

  void _initializeLocation() async {
    if (addActionsProvider.selectedLocation != null) {
      _selectedLocation = addActionsProvider.selectedLocation!;
      _selectedAddress = addActionsProvider.selectedAddress;
      _updateMarkerPosition();
      return;
    }

    savedLatitude = double.tryParse(
        mentalStrengthEditProvider.actionsDetailsModel?.actions?.location?.locationLatitude ?? "0.0"
    );
    savedLongitude = double.tryParse(
        mentalStrengthEditProvider.actionsDetailsModel?.actions?.location?.locationLongitude ?? "0.0"
    );
    savedLocationAddress = mentalStrengthEditProvider.actionsDetailsModel?.actions?.location?.locationAddress ?? "";

    logger.w("Saved Latitude: $savedLatitude");
    logger.w("Saved Longitude: $savedLongitude");

    if (savedLatitude != 0.0 && savedLongitude != 0.0) {
      _selectedLocation = LatLng(savedLatitude!, savedLongitude!);
      _selectedAddress = savedLocationAddress ?? '';
      _updateMarkerPosition();

      addActionsProvider.addLocationSection(
        selectedAddress: _selectedAddress,
        placemark: Placemark(
          name: '',
          locality: '',
          administrativeArea: '',
          country: '',
        ),
        location: _selectedLocation,
      );
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

  bool _isRequestingPermission = false;

  Future<void> _requestPermission() async {
    if (_isRequestingPermission) return;

    _isRequestingPermission = true;

    try {
      var status = await Permission.location.status;
      if (!status.isGranted) {
        await Permission.location.request();
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    } finally {
      _isRequestingPermission = false;
    }
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
          onTap: () {
            _onMapTapped(_selectedLocation);
          },
        ),
      );
    });
  }

  // 🔍 Search methods
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResultsWithNames.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      List<Map<String, dynamic>> resultsWithNames = [];

      for (var location in locations) {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
          if (placemarks.isNotEmpty) {
            Placemark placemark = placemarks[0];
            String displayName = '';

            if (placemark.name?.isNotEmpty ?? false) displayName = placemark.name!;
            if (placemark.locality?.isNotEmpty ?? false) {
              displayName += displayName.isNotEmpty ? ', ${placemark.locality}' : placemark.locality!;
            }
            if (placemark.administrativeArea?.isNotEmpty ?? false) {
              displayName += displayName.isNotEmpty ? ', ${placemark.administrativeArea}' : placemark.administrativeArea!;
            }
            if (placemark.country?.isNotEmpty ?? false) {
              displayName += displayName.isNotEmpty ? ', ${placemark.country}' : placemark.country!;
            }

            resultsWithNames.add({
              'location': location,
              'placemark': placemark,
              'displayName': displayName.isNotEmpty ? displayName : 'Unknown Location',
            });
          }
        } catch (e) {
          logger.e('Error getting placemark: $e');
        }
      }

      setState(() {
        _searchResultsWithNames = resultsWithNames;
        _isSearching = false;
      });
    } catch (e) {
      logger.e('Error searching location: $e');
      setState(() {
        _searchResultsWithNames.clear();
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not found. Please try a different search.')),
        );
      }
    }
  }

  Future<void> _selectSearchResult(Map<String, dynamic> result) async {
    Location location = result['location'];
    Placemark placemark = result['placemark'];
    LatLng selectedLatLng = LatLng(location.latitude, location.longitude);

    String address =
        '${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';

    setState(() {
      _selectedLocation = selectedLatLng;
      _selectedAddress = address;
      _searchResultsWithNames.clear(); // hide dropdown
      _searchController.text = result['displayName']; // ✅ keep the searched text
    });

    // ✅ Hide keyboard
    FocusScope.of(context).unfocus();

    // Move camera to selected location
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(selectedLatLng, 15.0),
    );

    // Update provider
    addActionsProvider.addLocationSection(
      selectedAddress: address,
      placemark: placemark,
      location: selectedLatLng,
    );

    _updateMarkerPosition();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.65,
      child: Column(
        children: [
          // Close Button Row
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

          // 🔍 Search Bar + Results
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        ImageConstant.searchIconMap, // ✅ your search SVG
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: SvgPicture.asset(
                        ImageConstant.clearIconMap, // ✅ your clear SVG
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResultsWithNames.clear();
                        });
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.grey, width: 0.1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.blue, width: 0.1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (value) => _searchLocation(value),
                ),
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                if (_searchResultsWithNames.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResultsWithNames.length,
                      itemBuilder: (context, index) {
                        final result = _searchResultsWithNames[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.red),
                          title: Text(
                            result['displayName'],
                            style: const TextStyle(fontSize: 14),
                          ),
                          dense: true,
                          onTap: () => _selectSearchResult(result),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🗺 Google Map
          Expanded(
            child: GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) {
                mapController = controller;
                if (_selectedLocation.latitude != 0 && _selectedLocation.longitude != 0) {
                  mapController.animateCamera(
                    CameraUpdate.newLatLngZoom(_selectedLocation, 15.0),
                  );
                }
              },
              onTap: _onMapTapped,
              initialCameraPosition: CameraPosition(
                target: (savedLatitude != 0.0 && savedLongitude != 0.0)
                    ? LatLng(savedLatitude!, savedLongitude!)
                    : (_currentLocation != null
                    ? LatLng(_currentLocation!.latitude, _currentLocation!.longitude)
                    : const LatLng(0.0, 0.0)),
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

          if (_selectedAddress.isNotEmpty || savedLocationAddress!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Selected Address: ${_selectedAddress.isNotEmpty ? _selectedAddress : savedLocationAddress}',
                style:  TextStyle(
                  color: ColorsContent.newThemeColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onMapTapped(LatLng location) async {
    final addActionsProvider = Provider.of<AddActionsProvider>(context, listen: false);
    setState(() {
      _selectedLocation = location;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        final address =
            '${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
        setState(() {
          _selectedAddress = address;
        });
        addActionsProvider.addLocationSection(
          selectedAddress: address,
          placemark: placemark,
          location: location,
        );
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
