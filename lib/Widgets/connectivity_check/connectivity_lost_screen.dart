import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_bloc.dart';


class NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.signal_wifi_off, size: 100),
            SizedBox(height: 20),
            Text('No Internet Connection', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Trigger a connectivity check
                context.read<ConnectivityBloc>().add(CheckConnectivity());
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}