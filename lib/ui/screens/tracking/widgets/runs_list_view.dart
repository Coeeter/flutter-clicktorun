import 'package:clicktorun_flutter/data/model/run_model.dart';
import 'package:clicktorun_flutter/data/repositories/run_repository.dart';
import 'package:clicktorun_flutter/data/repositories/storage_repository.dart';
import 'package:clicktorun_flutter/ui/screens/tracking/widgets/runs_list_item.dart';
import 'package:clicktorun_flutter/ui/utils/Screen.dart';
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

  Color get _baseColor {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[300]!;
  }

  Color get _highlightColor {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[600]!
        : Colors.grey[100]!;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: widget.isLoading
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        if (widget.isLoading) {
          return _getLoadingListItem();
        }
        GlobalKey<RunsListItemState> listItemKey = GlobalKey();
        allListItems.add(listItemKey);
        return FutureBuilder<String>(
          future: StorageRepository.instance().getDownloadUrl(
            Theme.of(context).brightness == Brightness.dark
                ? widget.runList![index].darkModeImage
                : widget.runList![index].lightModeImage,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _getLoadingListItem();
            }
            return RunsListItem(
              key: listItemKey,
              parentKey: widget.key as GlobalKey<RunsListViewState>,
              runModel: widget.runList![index],
              imageUrl: snapshot.data!,
              isSelectable: isSelectable,
              onDeleteTap: () async {
                widget.setLoading(true);
                await RunRepository.instance()
                    .deleteRun([widget.runList![index].id]);
                widget.setLoading(false);
              },
            );
          },
        );
      },
      itemCount: widget.isLoading ? 5 : widget.runList?.length,
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
              highlightColor: _highlightColor,
              baseColor: _baseColor,
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
            highlightColor: _highlightColor,
            baseColor: _baseColor,
            child: Container(
              height: 16,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 5),
          Shimmer.fromColors(
            highlightColor: _highlightColor,
            baseColor: _baseColor,
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
