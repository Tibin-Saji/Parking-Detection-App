import 'package:flutter/material.dart';

import '../notification.dart';

// class TestScreen extends StatelessWidget {
//   const TestScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: TextButton(
//         child: const Center(child: Text('Click Me')),
//         onPressed: () {
//           NotificationApi.showNotification(
//               //id: 1,
//               title: 'Low Parking!!!',
//               body:
//                   'There are less than 5 parking lots left. Click here if you want to change the location.',
//               payload: 'nothing');
//         },
//       ),
//     );
//   }
// }

class TextScreen extends StatefulWidget {
  const TextScreen({Key? key}) : super(key: key);

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(
        child: const Center(child: Text('Click Me')),
        onPressed: () {
          NotificationApi.showNotification(
              //id: 1,
              title: 'Low Parking!!!',
              body:
                  'There are less than 5 parking lots left. Click here if you want to change the location.',
              payload: 'nothing');
        },
      ),
    );
  }
}
