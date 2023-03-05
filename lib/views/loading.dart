import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool _isLoading = false; //bool variable created
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });
            await Future.delayed(const Duration(seconds: 5));
//for demo I had use delayed method. When you integrate use your api //call here.
            setState(() {
              _isLoading = false;
            });
          },
          child: const Text("Click to start fetching"),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.all(50),
          margin: const EdgeInsets.all(50),
          color: Colors.blue[100],
//widget shown according to the state
          child: Center(
            child: !_isLoading
                ? const Text("Loading Complete")
                : const CircularProgressIndicator(),
          ),
        )
      ],
    ));
  }
}
