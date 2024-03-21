import 'package:flutter/material.dart';

class VideoViewContainer extends StatelessWidget {
  final Widget child;
  final Color background_color;
  final String user_name;
  final bool user_is_local;
  final bool is_the_same_account;

  const VideoViewContainer({
    super.key,
    required this.child,
    required this.background_color,
    required this.user_name,
    required this.user_is_local,
    required this.is_the_same_account,
  });

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;

    String user_name_string = user_name;

    if (user_is_local) {
      user_name_string = "$user_name (You)";
    } else if (is_the_same_account) {
      user_name_string = "$user_name (Same Account)";
    }

    return Container(
      height: screen_height / 2.5,
      width: screen_height / 2.5,
      decoration: BoxDecoration(
        color: background_color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 3,
          color: Colors.grey,
        ),
      ),
      child: Column(
        children: [
          const Spacer(flex: 1),
          Expanded(
            flex: 40,
            child: child,
          ),
          const Spacer(flex: 1),
          Expanded(
            flex: 4,
            child: Text(
              user_name_string,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
