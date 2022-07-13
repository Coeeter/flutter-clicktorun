import 'package:clicktorun_flutter/data/model/user_model.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  double width;
  ColorScheme colorScheme;
  AsyncSnapshot<UserModel?> snapshot;
  void Function()? onTap;
  ProfileImage({
    required this.width,
    required this.colorScheme,
    required this.snapshot,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const ShapeDecoration(
        shape: CircleBorder(),
        shadows: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 2,
          ),
        ],
      ),
      child: Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            child: Container(
              width: width,
              height: width,
              alignment: Alignment.center,
              child: _checkLoading(
                context,
                snapshot,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _checkLoading(
    BuildContext context,
    AsyncSnapshot<UserModel?> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }

    if (snapshot.data?.profileImage == null) {
      return Icon(
        Icons.person,
        size: width,
        color: Colors.grey,
      );
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.network(
        snapshot.data!.profileImage!,
        fit: BoxFit.cover,
        loadingBuilder: _loadingBuilder,
      ),
    );
  }

  Widget _loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) return child;
    if (loadingProgress.expectedTotalBytes == null) {
      return const CircularProgressIndicator();
    }
    double percentLoaded = 1.0 *
        (loadingProgress.cumulativeBytesLoaded /
            loadingProgress.expectedTotalBytes!);
    return CircularProgressIndicator(
      value: percentLoaded,
    );
  }
}
