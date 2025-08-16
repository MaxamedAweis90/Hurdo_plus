import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _feedbackType = 'General';
  final List<String> _feedbackTypes = [
    'General',
    'Sounds',
    'App UI',
    'Bugs',
    'Suggestions',
  ];
  int _selectedFeeling =
      2; // 0: very sad, 1: sad, 2: neutral, 3: happy, 4: very happy
  final List<String> _emojis = ['😞', '🙁', '😐', '🙂', '😄'];
  final List<String> _labels = ['Very Bad', 'Bad', 'Medium', 'Good', 'Great'];
  bool _submitted = false;

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      setState(() => _submitted = true);
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Feedback'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _submitted
                ? Column(
                    key: const ValueKey('success'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.12,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: theme.colorScheme.primary,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Thank you!',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your feedback has been submitted.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                    ],
                  )
                : Column(
                    key: const ValueKey('form'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'How are you feeling?',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your input is valuable in helping us better understand your needs and tailor our service accordingly.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          _emojis.length,
                          (i) => GestureDetector(
                            onTap: () => setState(() => _selectedFeeling = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _selectedFeeling == i
                                    ? theme.colorScheme.primary.withOpacity(
                                        0.15,
                                      )
                                    : Colors.transparent,
                              ),
                              child: Text(
                                _emojis[i],
                                style: TextStyle(
                                  fontSize: _selectedFeeling == i ? 38 : 30,
                                  color: _selectedFeeling == i
                                      ? theme.colorScheme.primary
                                      : theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _labels[_selectedFeeling],
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Your Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface
                                    .withOpacity(0.08),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Please enter your name'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: _feedbackType,
                              items: _feedbackTypes
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _feedbackType = val);
                              },
                              decoration: InputDecoration(
                                labelText: 'Feedback About',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface
                                    .withOpacity(0.08),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                labelText: 'Add a Comment...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface
                                    .withOpacity(0.08),
                              ),
                              minLines: 3,
                              maxLines: 6,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Please enter your message'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _submit,
                            child: const Text(
                              'Send',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
