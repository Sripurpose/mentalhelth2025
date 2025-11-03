import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../utils/theme/colors.dart';
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
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  double? savedLatitude = 0.0;
  double? savedLongitude = 0.0;
  String? savedLocationAddress = '';
  String cacheSelectedAddress = '';
  var logger = Logger();

  // Search functionality variables
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResultsWithNames = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    mentalStrengthEditProvider = Provider.of<MentalStrengthEditProvider>(context, listen: false);

    // Use provider's selected location if available
    if (mentalStrengthEditProvider.selectedLocation != null) {
      _selectedLocation = mentalStrengthEditProvider.selectedLocation!;
      _selectedAddress = mentalStrengthEditProvider.selectedAddress;
      _updateMarkerPosition();
    } else if (widget.edit) {
      savedLatitude = double.parse(homeProvider.journalDetails?.journals?.location?.locationLatitude ?? "0.0");
      savedLongitude = double.parse(homeProvider.journalDetails?.journals?.location?.locationLongitude ?? "0.0");
      savedLocationAddress = homeProvider.journalDetails?.journals?.location?.locationAddress ?? "";

      if (savedLatitude != 0.0 && savedLongitude != 0.0) {
        _selectedLocation = LatLng(savedLatitude!, savedLongitude!);
        _selectedAddress = savedLocationAddress ?? '';
        _updateMarkerPosition();
        // Also update provider for persistence
        mentalStrengthEditProvider.addLocationSection(
          selectedAddress: _selectedAddress,
          placemark: Placemark(
            name: '', // You may want to parse this from savedLocationAddress if needed
            locality: '',
            administrativeArea: '',
            country: '',
          ),
          location: _selectedLocation,
        );
      } else {
        _fetchCurrentLocation();
      }
    } else {
      _fetchCurrentLocation();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          onTap: () {
            _onMapTapped(_selectedLocation); // Trigger the same logic as map tap
          },
        ),
      );
    });
  }

  final Set<Marker> _markers = {};

  // Search functionality methods
  //List<Map<String, dynamic>> _searchResultsWithNames = [];

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

      // Get placemark details for each location
      List<Map<String, dynamic>> resultsWithNames = [];
      for (var location in locations) {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
              location.latitude,
              location.longitude
          );
          if (placemarks.isNotEmpty) {
            Placemark placemark = placemarks[0];
            String displayName = '';

            if (placemark.name != null && placemark.name!.isNotEmpty) {
              displayName = placemark.name!;
            }
            if (placemark.locality != null && placemark.locality!.isNotEmpty) {
              displayName += displayName.isNotEmpty ? ', ${placemark.locality}' : placemark.locality!;
            }
            if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
              displayName += displayName.isNotEmpty ? ', ${placemark.administrativeArea}' : placemark.administrativeArea!;
            }
            if (placemark.country != null && placemark.country!.isNotEmpty) {
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

    String address = '${placemark.name}, ${placemark.locality}, '
        '${placemark.administrativeArea}, ${placemark.country}';

    setState(() {
      _selectedLocation = selectedLatLng;
      _selectedAddress = address;
      _searchResultsWithNames.clear(); // hide dropdown
      // _searchController.clear(); // ❌ remove this line to keep text
    });

    // Keep the text in the search box (optional: update it with selected address)
    _searchController.text = result['displayName'];

    // Animate to the selected location
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(selectedLatLng, 15.0),
    );

    // Update provider
    mentalStrengthEditProvider.addLocationSection(
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
      height: size.height * 0.75,
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

          // Search Bar
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
                      borderSide: const BorderSide(color: Colors.grey, width: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey, width: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey, width: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    _searchLocation(value);
                  },
                ),

                // Search Results Dropdown
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

                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                if (_selectedLocation.latitude != 0 && _selectedLocation.longitude != 0) {
                  mapController.animateCamera(
                    CameraUpdate.newLatLngZoom(_selectedLocation, 15.0),
                  );
                }
              },
              onTap: _onMapTapped,
              initialCameraPosition: CameraPosition(
                target: (widget.edit && savedLatitude != 0.0 && savedLongitude != 0.0)
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

          _selectedAddress.isNotEmpty || savedLocationAddress!.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Selected Address: ${_selectedAddress.isNotEmpty ? _selectedAddress.replaceAll(RegExp(r'[^a-zA-Z0-9\s,]'), '').trim() : (widget.edit ? savedLocationAddress?.replaceAll(RegExp(r'[^a-zA-Z0-9\s,]'), '').trim() : "")}',
              style: TextStyle(
                color: ColorsContent.newThemeColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          )
              : const SizedBox(),
        ],
      ),
    );
  }

  void _onMapTapped(LatLng location) async {
    setState(() {
      _selectedLocation = location;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address = '${placemark.name}, ${placemark.locality}, '
            '${placemark.administrativeArea}, ${placemark.country}';
        setState(() {
          _selectedAddress = address;
        });
        mentalStrengthEditProvider.addLocationSection(
          selectedAddress: address,
          placemark: placemark,
          location: location,
        );
      }
      _updateMarkerPosition();
    } catch (e) {}
  }

  void _onMarkerDragEnd(LatLng location) {
    _onMapTapped(location);
  }
}