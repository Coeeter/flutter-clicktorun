import 'package:clicktorun_flutter/data/model/clicktorun_user.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  double width;
  ColorScheme colorScheme;
  AsyncSnapshot<UserModel?> snapshot;
  ProfileImage({
    required this.width,
    required this.colorScheme,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        color: colorScheme.surface,
        shadows: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 2,
          )
        ],
      ),
      child: snapshot.connectionState == ConnectionState.waiting
          ? const CircularProgressIndicator()
          : snapshot.data?.profileImage == null
              ? Icon(
                  Icons.person,
                  size: width,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey
                      : Colors.black,
                )
              : SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.network(
                    snapshot.data!.profileImage!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
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
                    },
                  ),
                ),
    );
  }
}
