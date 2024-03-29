import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/repositories/position_repository.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/data/repositories/storage_repository.dart';
import 'package:clicktorun_flutter/ui/screens/home/widgets/runs_list_item.dart';
import 'package:clicktorun_flutter/ui/utils/Screen.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RunsListView extends StatefulWidget {
  final List<RunModel>? runList;
  final bool isLoading;
  final void Function(int) updateTitle;
  final void Function(bool) setLoading;
  const RunsListView({
    required Key key,
    required this.runList,
    required this.isLoading,
    required this.updateTitle,
    required this.setLoading,
  }) : super(key: key);

  @override
  State<RunsListView> createState() => RunsListViewState();
}

class RunsListViewState extends State<RunsListView> {
  List<GlobalKey<RunsListItemState>> allListItems = [];
  bool isSelectable = false;

  List<String> get selectedItems {
    List<String> selected = [];
    for (GlobalKey<RunsListItemState> listItem in allListItems) {
      if (listItem.currentState?.isSelected == true) {
        selected.add(
          listItem.currentState!.widget.runModel.id,
        );
      }
    }
    return selected;
  }

  int get selectedCount {
    return selectedItems.length;
  }

  void updateTitle() {
    widget.updateTitle(selectedCount);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = widget.isLoading
        ? List.filled(5, _getLoadingListItem())
        : widget.runList!.map((RunModel runModel) {
            GlobalKey<RunsListItemState> listItemKey = GlobalKey();
            allListItems.add(listItemKey);
            return FutureBuilder<String>(
              future: StorageRepository.instance().getDownloadUrl(
                Theme.of(context).brightness == Brightness.dark
                    ? runModel.darkModeImage
                    : runModel.lightModeImage,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _getLoadingListItem();
                }
                return RunsListItem(
                  key: listItemKey,
                  parentKey: widget.key as GlobalKey<RunsListViewState>,
                  runModel: runModel,
                  imageUrl: snapshot.data!,
                  isSelectable: isSelectable,
                  onDeleteTap: () async {
                    widget.setLoading(true);
                    await RunRepository.instance().deleteRun([
                      runModel.id,
                    ]);
                    await PositionRepository.instance().deleteRunRoute(
                      runModel.id,
                    );
                    widget.setLoading(false);
                  },
                  onShareTap: () async {
                    await RunRepository.instance().shareRun(runModel.id, true);
                    SnackbarUtils(context: context).createSnackbar(
                      'Shared run successfully',
                    );
                  },
                  onRemoveShareTap: () async {
                    await RunRepository.instance().shareRun(runModel.id, false);
                    SnackbarUtils(context: context).createSnackbar(
                      'Hided run successfully',
                    );
                  },
                );
              },
            );
          }).toList();

    return SingleChildScrollView(
      physics: widget.isLoading
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _getLoadingListItem() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Material(
        elevation: 10,
        child: Column(
          children: [
            Shimmer.fromColors(
              highlightColor: ClickToRunColors.gethighlightColor(context),
              baseColor: ClickToRunColors.getbaseColor(context),
              child: Container(
                width: Screen.width - 20,
                height: (Screen.width - 20) / 2,
                color: Colors.grey[300]!,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _getPlaceholderText(),
                  _getPlaceholderText(),
                  _getPlaceholderText(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getPlaceholderText() {
    return Container(
      width: (Screen.width - 40) / 3,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Shimmer.fromColors(
            highlightColor: ClickToRunColors.gethighlightColor(context),
            baseColor: ClickToRunColors.getbaseColor(context),
            child: Container(
              height: 20,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 5),
          Shimmer.fromColors(
            highlightColor: ClickToRunColors.gethighlightColor(context),
            baseColor: ClickToRunColors.getbaseColor(context),
            child: Container(
              height: 14,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}
