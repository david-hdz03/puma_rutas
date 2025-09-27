
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'database_helper.dart';

class RouteDetailScreen extends StatefulWidget {
  final int routeId;
  final String routeName;
  final Color routeColor;

  const RouteDetailScreen({
    super.key,
    required this.routeId,
    required this.routeName,
    required this.routeColor,
  });

  @override
  RouteDetailScreenState createState() => RouteDetailScreenState();
}

class RouteDetailScreenState extends State<RouteDetailScreen> {
  late Future<List<Map<String, dynamic>>> _stationsFuture;

  @override
  void initState() {
    super.initState();
    _stationsFuture = DatabaseHelper.instance.getStationsForRoute(widget.routeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ruta ${widget.routeName}'),
        backgroundColor: widget.routeColor,
      ),
      body: Stack(
        children: [
          PhotoView(
            imageProvider: AssetImage('assets/images/route-${widget.routeName}.jpg'),
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 50,
                  ),
                ),
              );
            },
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.8,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _stationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No hay estaciones para esta ruta.'),
                        ),
                      );
                    }

                    final stations = snapshot.data!;
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: stations.length,
                      itemBuilder: (context, index) {
                        final station = stations[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: widget.routeColor,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            station['name'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
