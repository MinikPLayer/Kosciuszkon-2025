import 'package:flutter/material.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier<int>(0);
ValueNotifier<bool> isLightModeNotifier = ValueNotifier<bool>(true);

Widget buildBackButton() {
  return ValueListenableBuilder<int>(
    valueListenable: selectedPageNotifier,
    builder: (context, selectedPage, child) {
      return selectedPage != 0
          ? IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              selectedPageNotifier.value = 0; // wróć do HomePage
            },
            tooltip: 'Powrót',
          )
          : IconButton(
            onPressed:
                Navigator.canPop(context)
                    ? () {
                      Navigator.of(context).pop();
                    }
                    : null,
            icon: Icon(Icons.arrow_back),
          );
    },
  );
}
