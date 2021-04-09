import 'package:beaconflutter/screens/follow_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Future<String> getClipBoardData() async {
    final ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
    return data.text;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beacon Flutter'),
      ),
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/carryScreen');
              },
              child: const Text('Carry the Beacon'),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                _controller.clear();
                showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return _buildDialog(setState);
                      });
                    });
              },
              child: const Text('Follow the Beacon'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialog(StateSetter setState) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Enter pass key',
                suffixIcon: InkWell(
                  onTap: () async {
                    final passKey = await getClipBoardData();
                    setState(() => _controller.text = passKey);
                    _focusNode.unfocus();
                  },
                  child: const Icon(Icons.paste),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FollowScreen(
                        passKey: _controller.text.trim(),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Lets follow it!',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
