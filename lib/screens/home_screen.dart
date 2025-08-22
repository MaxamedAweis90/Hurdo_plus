import 'package:flutter/material.dart';
import '../widgets/hurdo_drawer.dart';
import '../widgets/playback_controls.dart';
import '../widgets/sound_card.dart';
// import '../widgets/all_sounds_popup.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int)? onThemeChanged;
  final int? selectedTheme;
  final double topSpace;
  final double bottomSpace;
  const HomeScreen({
    super.key,
    this.onThemeChanged,
    this.selectedTheme,
    this.topSpace = 65,
    this.bottomSpace = 160,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Hurdo+'),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Choose Theme',
              icon: const Icon(Icons.palette_outlined),
              onPressed: () {
                showDialog(
                  context: scaffoldKey.currentContext ?? context,
                  builder: (context) => _ThemePickerDialog(
                    selectedTheme: selectedTheme ?? 0,
                    onThemeSelected: onThemeChanged,
                  ),
                );
              },
            ),
          ],
        ),
        drawer: const HurdoDrawer(),
        body: Stack(
          children: [
            // Grid content fills available space and scrolls under the controller
            Positioned.fill(
              child: RawScrollbar(
                thumbVisibility: true,
                thickness: 4,
                radius: const Radius.circular(8),
                padding: EdgeInsets.only(top: topSpace, bottom: bottomSpace),
                child: CustomScrollView(
                  primary: true,
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: topSpace)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 20,
                              childAspectRatio: 0.95,
                            ),
                        delegate: SliverChildListDelegate(const [
                          SoundCard(
                            icon: Icons.cloud,
                            initialVolume: 0.7,
                            label: 'Rain',
                          ),
                          SoundCard(
                            icon: Icons.water_drop,
                            initialVolume: 0.5,
                            label: 'Water',
                          ),
                          SoundCard(
                            icon: Icons.bubble_chart,
                            initialVolume: 0.3,
                            label: 'Drain',
                          ),
                          SoundCard(
                            icon: Icons.bubble_chart,
                            initialVolume: 0.3,
                            label: 'Drain',
                          ),
                          SoundCard(
                            icon: Icons.bubble_chart,
                            initialVolume: 0.3,
                            label: 'Drain',
                          ),
                          SoundCard(
                            icon: Icons.bubble_chart,
                            initialVolume: 0.3,
                            label: 'Drain',
                          ),
                          SoundCard(
                            icon: Icons.nightlight_round,
                            initialVolume: 0.8,
                            label: 'Night',
                          ),
                          SoundCard(
                            icon: Icons.forest,
                            initialVolume: 0.6,
                            label: 'Forest',
                          ),
                          SoundCard(
                            icon: Icons.bolt,
                            initialVolume: 0.4,
                            label: 'Thunder',
                          ),
                        ]),
                      ),
                    ),
                    // Bottom spacer so the last row can scroll above the controller
                    SliverToBoxAdapter(child: SizedBox(height: bottomSpace)),
                  ],
                ),
              ),
            ),
            // Overlay the playback controller at the bottom center
            const Align(
              alignment: Alignment.bottomCenter,
              child: PlaybackControls(),
            ),
          ],
        ),
        // Removed floatingActionButton, theme button is now in AppBar
      ),
    );
  }
}

// Theme picker dialog widget for FAB
class _ThemePickerDialog extends StatefulWidget {
  final int selectedTheme;
  final void Function(int)? onThemeSelected;
  const _ThemePickerDialog({required this.selectedTheme, this.onThemeSelected});

  @override
  State<_ThemePickerDialog> createState() => _ThemePickerDialogState();
}

class _ThemePickerDialogState extends State<_ThemePickerDialog> {
  int? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedTheme;
  }

  @override
  Widget build(BuildContext context) {
    final themeOptions = [
      {'name': 'Ocean Blue', 'color': Colors.blueAccent},
      {'name': 'Sunset Orange', 'color': Colors.deepOrangeAccent},
      {'name': 'Forest Green', 'color': Colors.green},
      {'name': 'Purple Night', 'color': Colors.deepPurple},
      {'name': 'Teal Dream', 'color': Colors.teal},
    ];
    return AlertDialog(
      title: const Text('Choose Theme'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < themeOptions.length; i++)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: themeOptions[i]['color'] as Color,
                ),
                title: Text(themeOptions[i]['name'] as String),
                trailing: Radio<int>(
                  value: i,
                  groupValue: _selected,
                  onChanged: (v) {
                    if (!mounted) return; // Prevent setState after dispose
                    setState(() => _selected = v);
                  },
                ),
                onTap: () {
                  if (!mounted) return; // Prevent setState after dispose
                  setState(() => _selected = i);
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selected != null && widget.onThemeSelected != null
              ? () {
                  widget.onThemeSelected!(_selected!);
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
