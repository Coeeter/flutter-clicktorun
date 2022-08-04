import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/ui/screens/home/run_details_screen.dart';
import 'package:clicktorun_flutter/ui/screens/home/widgets/runs_list_view.dart';
import 'package:clicktorun_flutter/ui/utils/Screen.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';

class RunsListItem extends StatefulWidget {
  final GlobalKey<RunsListViewState> parentKey;
  final RunModel runModel;
  final bool isSelectable;
  final String imageUrl;
  final void Function() onDeleteTap;
  final void Function() onShareTap;
  final void Function() onRemoveShareTap;

  const RunsListItem({
    required Key? key,
    required this.parentKey,
    required this.runModel,
    required this.imageUrl,
    required this.isSelectable,
    required this.onDeleteTap,
    required this.onShareTap,
    required this.onRemoveShareTap,
  }) : super(key: key);

  @override
  State<RunsListItem> createState() => RunsListItemState();
}

class RunsListItemState extends State<RunsListItem> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    GlobalKey globalKey = GlobalKey();
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          if (!widget.isSelectable) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return RunDetailsScreen(
                    runModel: widget.runModel,
                  );
                },
              ),
            );
            return;
          }
          setState(() {
            isSelected = !isSelected;
          });
          widget.parentKey.currentState?.updateTitle();
        },
        child: Slidable(
          key: ValueKey(widget.runModel.id),
          startActionPane: widget.isSelectable
              ? null
              : _getShareActionPane(widget.runModel, widget.runModel.isShared),
          endActionPane:
              widget.isSelectable ? null : _getActionPane(widget.runModel),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                Material(
                  key: globalKey,
                  elevation: 10,
                  child: Column(
                    children: [
                      SizedBox(
                        width: Screen.width - 20,
                        height: (Screen.width - 20) / 2,
                        child: _getImage(widget.runModel),
                      ),
                      _getDetailsRow(widget.runModel),
                    ],
                  ),
                ),
                _getOverlay(widget.runModel.id),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ActionPane _getShareActionPane(RunModel runModel, bool isShared) {
    return ActionPane(
      motion: const ScrollMotion(),
      children: [
        SlidableAction(
          onPressed: (_) {
            isShared? widget.onRemoveShareTap() : widget.onShareTap();
          },
          icon: isShared? Icons.archive : Icons.share,
          label: isShared? 'Hide run' : 'Save run',
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        )
      ],
    );
  }

  ActionPane _getActionPane(RunModel runModel) {
    return ActionPane(
      motion: const ScrollMotion(),
      dismissible: DismissiblePane(
        onDismissed: () {
          widget.onDeleteTap();
        },
      ),
      children: [
        SlidableAction(
          onPressed: (_) {
            widget.onDeleteTap();
          },
          icon: Icons.delete,
          label: 'Delete run',
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        )
      ],
    );
  }

  Widget _getImage(RunModel runModel) {
    return Hero(
      tag: 'image-${runModel.id}',
      child: Image.network(
        widget.imageUrl,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Shimmer.fromColors(
            highlightColor: ClickToRunColors.gethighlightColor(context),
            baseColor: ClickToRunColors.getbaseColor(context),
            child: Container(
              height: (Screen.width - 20) / 2,
              width: Screen.width - 20,
              color: ClickToRunColors.getbaseColor(context),
            ),
          );
        },
      ),
    );
  }

  Widget _getDetailsRow(RunModel runModel) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _getValue(
            context,
            (runModel.distanceRanInMetres > 1000
                    ? runModel.distanceRanInMetres / 1000
                    : runModel.distanceRanInMetres.toInt())
                .toString(),
            runModel.distanceRanInMetres > 1000 ? 'km' : 'm',
          ),
          _getValue(
            context,
            runModel.timeTakenInMilliseconds.toTimeString(),
            'Time',
          ),
          _getValue(
            context,
            runModel.averageSpeed.toStringAsFixed(2),
            'km/h',
          ),
        ],
      ),
    );
  }

  Widget _getValue(BuildContext context, String value, String unit) {
    return SizedBox(
      width: (Screen.width - 40) / 3,
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  overflow: TextOverflow.ellipsis,
                ),
          ),
          Text(
            unit,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }

  Widget _getOverlay(String id) {
    return Visibility(
      visible: isSelected,
      child: Container(
        alignment: Alignment.topRight,
        padding: const EdgeInsets.all(5),
        color: Theme.of(context).focusColor,
        child: const Icon(
          Icons.check_box,
          color: ClickToRunColors.secondary,
          size: 50,
        ),
      ),
    );
  }
}
