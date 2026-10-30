import 'package:flutter/material.dart';
import 'package:is_it_raining/pages/thanks.dart';
import 'package:url_launcher/url_launcher.dart';

class FoundABugPage extends StatefulWidget {
  const FoundABugPage({super.key});

  @override
  State<FoundABugPage> createState() => _FoundABugPageState();
}

class _FoundABugPageState extends State<FoundABugPage> {
  final TextEditingController _bugController = TextEditingController();
  final String _googleFormUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSc4tY7HeAa8zuiw3WMHmZC-o2bNKtbRn7oPI6Kd5U04oUx_wA/formResponse?usp=pp_url&entry.588312649=';
  bool _isSubmitting = false;

  Future<void> _submitBug() async {
    final message = _bugController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tell us what bug you found.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final submittedUrl = Uri.parse(
        '$_googleFormUrl${Uri.encodeQueryComponent(message)}',
      );

      if (!await launchUrl(
        submittedUrl,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not open Google Form');
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ThanksPage()),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open the bug form. Please try again or contact support.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _bugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "FOUND A \nBUG?",
              style: TextStyle(fontFamily: 'RainFont', fontSize: 44),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: TextField(
                controller: _bugController,
                maxLines: 6,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tell us more ...',
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitBug,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Color.fromRGBO(52, 184, 255, 1),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                backgroundColor: const Color.fromRGBO(52, 184, 255, 1),
              ),
              child:
                  _isSubmitting
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        'SUBMIT',
                        style: TextStyle(
                          fontFamily: 'RainFont',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
