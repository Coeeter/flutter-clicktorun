import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/model/user_model.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/data/repositories/storage_repository.dart';
import 'package:clicktorun_flutter/data/repositories/user_repository.dart';
import 'package:clicktorun_flutter/ui/screens/home/run_details_screen.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/widgets/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostItem extends StatefulWidget {
  final RunModel run;
  const PostItem({
    required this.run,
    Key? key,
  }) : super(key: key);

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  String? username;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 20;
    DateTime postedDate = DateTime.fromMillisecondsSinceEpoch(
        widget.run.timeStartedInMilliseconds);
    String units = 'am';
    if (postedDate.hour > 12) units = 'pm';
    String postedOnTime =
        "${_formatTime(postedDate.hour)}:${_formatTime(postedDate.minute)}:${_formatTime(postedDate.second)}$units";
    String postedOn =
        "$postedOnTime - ${postedDate.day}/${postedDate.month}/${postedDate.year}";
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
      ),
      child: GestureDetector(
        onTap: () {
          if (username == null) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RunDetailsScreen(
                runModel: widget.run,
                username: username,
              ),
            ),
          );
        },
        child: Material(
          elevation: 10,
          child: Column(
            children: [
              _getHeader(widget.run),
              SizedBox(
                width: width,
                height: width / 2,
                child: _getImage(
                  Theme.of(context).brightness == Brightness.dark
                      ? widget.run.darkModeImage
                      : widget.run.lightModeImage,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Ran on $postedOn',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontSize: 14, fontFamily: 'Roboto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getHeader(RunModel runModel) {
    return StreamBuilder<UserModel?>(
      stream: UserRepository.instance().getUserStream(runModel.email),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            highlightColor: ClickToRunColors.gethighlightColor(context),
            baseColor: ClickToRunColors.getbaseColor(context),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: Material(
                          shape: CircleBorder(),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        width: 100,
                        height: 20,
                        color: ClickToRunColors.getbaseColor(context),
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 20,
                    color: ClickToRunColors.getbaseColor(context),
                  )
                ],
              ),
            ),
          );
        }
        username = snapshot.data!.username;

        return Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: ProfileImage(
                      width: 32,
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            surface:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF303030)
                                    : Colors.white,
                          ),
                      snapshot: snapshot,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    snapshot.data!.username,
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontFamily: 'Roboto'),
                  ),
                ],
              ),
              Visibility(
                visible: snapshot.data!.email !=
                    AuthRepository.instance().currentUser!.email,
                child: Material(
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        'Follow',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: ClickToRunColors.primary,
                              fontFamily: 'Roboto',
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              if (snapshot.data!.email ==
                  AuthRepository.instance().currentUser!.email)
                Material(
                  child: InkWell(
                    onTap: () {
                      RunRepository.instance().shareRun(runModel.id, false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        'Hide post',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: ClickToRunColors.primary,
                              fontFamily: 'Roboto',
                            ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(int time) {
    if (time < 10) return "0$time";
    return time.toString();
  }

  Widget _getImage(String storagePath) {
    return Hero(
      tag: 'image-${widget.run.id}',
      child: FutureBuilder<String>(
        future: StorageRepository.instance().getDownloadUrl(
          storagePath,
        ),
        builder: (context, snapshot) {
          var loadingWidget = Shimmer.fromColors(
            child: Container(color: ClickToRunColors.getbaseColor(context)),
            baseColor: ClickToRunColors.getbaseColor(context),
            highlightColor: ClickToRunColors.gethighlightColor(context),
          );
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingWidget;
          }
          return Image.network(
            snapshot.data!,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return loadingWidget;
            },
          );
        },
      ),
    );
  }
}
