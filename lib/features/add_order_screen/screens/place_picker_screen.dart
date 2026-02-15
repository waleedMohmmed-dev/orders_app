import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PlacePickerScreen extends StatefulWidget {
  const PlacePickerScreen({super.key});

  @override
  State<PlacePickerScreen> createState() => _PlacePickerScreenState();
}

class _PlacePickerScreenState extends State<PlacePickerScreen> {
  GoogleMapController? mapController;
  LatLng selectedLocation = const LatLng(29.378586, 47.990341);
  String address = "اختر الموقع";
  bool isLoading = false;
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          showSnackBar("خدمة الموقع غير مفعلة", isError: true);
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            showSnackBar("تم رفض إذن الموقع", isError: true);
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          showSnackBar("يرجى تفعيل إذن الموقع من الإعدادات", isError: true);
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(selectedLocation, 15),
      );

      await _getAddressFromLatLng(selectedLocation);
    } catch (e) {
      debugPrint("Error getting location: $e");
      if (mounted) {
        showSnackBar("فشل في الحصول على موقعك الحالي", isError: true);
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    setState(() => isLoading = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        setState(() {
          address = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : "موقع بدون عنوان";
        });
      } else {
        setState(() => address = "موقع بدون عنوان");
      }
    } catch (e) {
      debugPrint("Error getting address: $e");
      setState(() => address = "موقع بدون عنوان");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _searchPlace(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => isSearching = true);

    List<String> searchQueries = [
      query,
      "$query, الكويت",
      "$query, Kuwait",
      "$query, KW",
    ];

    bool found = false;

    for (String searchQuery in searchQueries) {
      if (found) break;

      try {
        List<Location> locations = await locationFromAddress(searchQuery);
        if (locations.isNotEmpty) {
          setState(() {
            selectedLocation = LatLng(
              locations.first.latitude,
              locations.first.longitude,
            );
          });

          mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(selectedLocation, 15),
          );

          await _getAddressFromLatLng(selectedLocation);
          found = true;

          FocusScope.of(context).unfocus();
        }
      } catch (e) {
        debugPrint("Search attempt failed for: $searchQuery - $e");
        continue;
      }
    }

    setState(() => isSearching = false);

    if (!found && mounted) {
      showSnackBar(
        "لم يتم العثور على '$query'\nجرب كتابة العنوان بشكل أوضح",
        isError: true,
      );
    }
  }

  void showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              mapController = controller;
            },
            onTap: (location) {
              setState(() => selectedLocation = location);
              _getAddressFromLatLng(location);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: selectedLocation,
                draggable: true,
                onDragEnd: (location) {
                  setState(() => selectedLocation = location);
                  _getAddressFromLatLng(location);
                },
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            },
          ),

          // Top Controls (Back Button + Search Bar)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Back Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                ),

                const SizedBox(width: 12),

                // Search Bar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: "ابحث عن مكان، شارع، أو منطقة...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(14.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Icon(Icons.search),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: _searchPlace,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Location Info Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag Handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Location Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "الموقع المحدد",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              isLoading
                                  ? Row(
                                      children: [
                                        SizedBox(
                                          height: 14,
                                          width: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "جاري تحديد العنوان...",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      address,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.pop({
                                  'latLng': selectedLocation,
                                  'address': address,
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "تأكيد الموقع",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // My Location Button
          Positioned(
            bottom: 220,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: getCurrentLocation,
                backgroundColor: Colors.white,
                elevation: 0,
                mini: true,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    searchController.dispose();
    super.dispose();
  }
}
