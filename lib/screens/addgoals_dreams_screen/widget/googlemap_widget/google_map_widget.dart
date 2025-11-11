import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../utils/theme/colors.dart';
import '../../../goals_dreams_page/model/goals_and_dreams_model.dart' hide Location;

class AddGoalsGoogleMap extends StatefulWidget {
  const AddGoalsGoogleMap({
    super.key,
    this.goalsanddream,
    this.isEdit = false,
  });

  final Goalsanddream? goalsanddream;
  final bool isEdit;

  @override
  _AddGoalsGoogleMapState createState() => _AddGoalsGoogleMapState();
}

class _AddGoalsGoogleMapState extends State<AddGoalsGoogleMap> {
  PermissionStatus permissionStatus = PermissionStatus.denied;
  Position? _currentLocation;
  late AdDreamsGoalsProvider adDreamsGoalsProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  double? savedLatitude = 0.0;
  double? savedLongitude = 0.0;
  String? savedLocationAddress = '';
  var logger = Logger();

  // Search functionality variables
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResultsWithNames = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    adDreamsGoalsProvider = Provider.of<AdDreamsGoalsProvider>(context, listen: false);
    mentalStrengthEditProvider = Provider.of<MentalStrengthEditProvider>(context, listen: false);

    // Check if provider already has a selected location (persisted from previous interaction)
    if (adDreamsGoalsProvider.selectedLocation != null) {
      _selectedLocation = adDreamsGoalsProvider.selectedLocation!;
      _selectedAddress = adDreamsGoalsProvider.selectedAddress;
      _updateMarkerPosition();
    } else {
      // Retrieve saved location from the model if available
      if (widget.isEdit) {
        // Use goalDetailModel when in edit mode
        final goalDetailModel = mentalStrengthEditProvider.goalDetailModel;
        savedLatitude = double.parse(goalDetailModel?.goals?.location?.locationLatitude ?? "0.0");
        savedLongitude = double.parse(goalDetailModel?.goals?.location?.locationLongitude ?? "0.0");
        savedLocationAddress = goalDetailModel?.goals?.location?.locationAddress ?? "";
      } else {
        // Use goalsanddream when in add mode
        savedLatitude = double.parse(widget.goalsanddream?.location?.locationLatitude ?? "0.0");
        savedLongitude = double.parse(widget.goalsanddream?.location?.locationLongitude ?? "0.0");
        savedLocationAddress = widget.goalsanddream?.location?.locationAddress ?? "";
      }

      logger.w("Saved Latitude: $savedLatitude");
      logger.w("Saved Longitude: $savedLongitude");

      if (savedLatitude != 0.0 && savedLongitude != 0.0) {
        _selectedLocation = LatLng(savedLatitude!, savedLongitude!);
        _selectedAddress = savedLocationAddress ?? '';
        _updateMarkerPosition();

        // Also update provider for persistence
        adDreamsGoalsProvider.addLocationSection(
          selectedAddress: _selectedAddress,
          placemark: Placemark(
            name: '', // Optionally parse from address string if needed
            locality: '',
            administrativeArea: '',
            country: '',
          ),
          location: _selectedLocation,
        );
      } else {
        _fetchCurrentLocation();
      }
    }

    _searchController.addListener(() {
      setState(() {});
    });
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
          onTap: () {
            _onMapTapped(_selectedLocation);
          },
        ),
      );
    });
  }

  final Set<Marker> markers = {};

  // Helper method to build display name from placemark
  String _buildDisplayName(Placemark placemark) {
    List<String> parts = [];

    if (placemark.name != null && placemark.name!.isNotEmpty) {
      parts.add(placemark.name!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      if (!parts.contains(placemark.locality)) {
        parts.add(placemark.locality!);
      }
    }
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      if (!parts.contains(placemark.administrativeArea)) {
        parts.add(placemark.administrativeArea!);
      }
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      if (!parts.contains(placemark.country)) {
        parts.add(placemark.country!);
      }
    }

    return parts.join(', ');
  }

  // Search functionality methods - IMPROVED FOR 10 NEARBY LOCATIONS
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

      if (locations.isNotEmpty) {
        Location mainLocation = locations[0];

        // Create a larger grid of search points for more results
        double lat = mainLocation.latitude;
        double lng = mainLocation.longitude;
        double offset = 0.03; // ~3km offset for denser grid

        List<LatLng> searchPoints = [
          LatLng(lat, lng),
          LatLng(lat + offset, lng),
          LatLng(lat - offset, lng),
          LatLng(lat, lng + offset),
          LatLng(lat, lng - offset),
          LatLng(lat + offset, lng + offset),
          LatLng(lat - offset, lng - offset),
          LatLng(lat + offset, lng - offset),
          LatLng(lat - offset, lng + offset),
          LatLng(lat + offset * 2, lng),
          LatLng(lat - offset * 2, lng),
          LatLng(lat, lng + offset * 2),
          LatLng(lat, lng - offset * 2),
        ];

        // Get placemarks for each search point
        for (var point in searchPoints) {
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(
              point.latitude,
              point.longitude,
            );
            if (placemarks.isNotEmpty) {
              Placemark placemark = placemarks[0];
              String displayName = _buildDisplayName(placemark);

              // Avoid duplicate entries
              bool isDuplicate = resultsWithNames.any((r) =>
              r['displayName'] == displayName
              );

              if (!isDuplicate && displayName.isNotEmpty) {
                resultsWithNames.add({
                  'location': Location(
                    latitude: point.latitude,
                    longitude: point.longitude,
                    timestamp: DateTime.now(),
                  ),
                  'placemark': placemark,
                  'displayName': displayName,
                });
              }
            }
          } catch (e) {
            logger.e('Error getting placemark for nearby: $e');
          }
        }
      }

      setState(() {
        // Limit to 10 results
        _searchResultsWithNames = resultsWithNames.take(10).toList();
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
      _searchResultsWithNames.clear(); // hide the dropdown
      _searchController.text = result['displayName']; // ✅ keep searched text
    });

    // ✅ Hide keyboard after selection
    FocusScope.of(context).unfocus();

    // Animate to the selected location
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(selectedLatLng, 15.0),
    );

    // Update provider
    adDreamsGoalsProvider.addLocationSection(
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
                  imagePath: ImageConstant.imgClosePrimary,
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
                        ImageConstant.searchIconMap,
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: SvgPicture.asset(
                        ImageConstant.clearIconMap,
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
                      borderSide: const BorderSide(color: Colors.blue, width: 0.1),
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
                    constraints: const BoxConstraints(maxHeight: 250),
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
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
                target: (savedLatitude != 0.0 && savedLongitude != 0.0)
                    ? LatLng(savedLatitude!, savedLongitude!)
                    : (_currentLocation != null
                    ? LatLng(_currentLocation!.latitude, _currentLocation!.longitude)
                    : const LatLng(0.0, 0.0)),
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

          _selectedAddress.isNotEmpty || savedLocationAddress!.isNotEmpty
              ? Padding(
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
          )
              : const SizedBox(),
        ],
      ),
    );
  }

  void _onMapTapped(LatLng location) async {
    // Get the provider instance only once
    final adDreamsGoalsProvider = Provider.of<AdDreamsGoalsProvider>(context, listen: false);

    // Optimistically update the local marker
    setState(() {
      _selectedLocation = location;
    });

    try {
      // Get the address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        final address = '${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';

        // Update local state and provider
        setState(() {
          _selectedAddress = address;
        });
        adDreamsGoalsProvider.addLocationSection(
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