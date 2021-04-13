import 'package:flutter/material.dart';

class EmptyContent extends StatelessWidget {
  const EmptyContent({
    Key key,
    @required this.title,
    @required this.desc,
  }) : super(key: key);
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 6.0),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle2.copyWith(
                    color: Colors.black45,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
